import json
import uuid
from datetime import UTC, date, datetime, time, timedelta
from zoneinfo import ZoneInfo

from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel, Field, field_validator

from ..db import audit, get_conn
from ..deps_pro import current_dietitian, require_linked_patient
from ..notify import notify
from ..pdf import report_pdf
from ..routers.files import save_bytes
from ..sms import get_sms

router = APIRouter(prefix="/pro", tags=["pro"])
TZ = ZoneInfo("Africa/Douala")
LABELS = ["Petit-déjeuner", "Déjeuner", "Collation", "Dîner"]
DAYS = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"]


def _initials(name: str) -> str:
    parts = [p for p in name.split() if p]
    return ("".join(p[0] for p in (parts[:1] + parts[-1:] if len(parts) > 1 else parts))).upper()


def _num(v):
    return None if v is None else float(v)


# ---------- Agenda et demandes ----------
@router.get("/agenda")
def agenda(week_start: date = Query(...), dz=Depends(current_dietitian), conn=Depends(get_conn)):
    monday = week_start - timedelta(days=week_start.weekday())
    start = datetime.combine(monday, time(0), TZ)
    rows = conn.execute(
        """select a.id, a.starts_at, a.mode, a.status, u.full_name from appointments a
           join users u on u.id = a.patient_id
           where a.dietitian_id = %s and a.status = 'confirmed' and a.starts_at >= %s and a.starts_at < %s
           order by a.starts_at""",
        (dz["dietitian_id"], start, start + timedelta(days=7)),
    ).fetchall()
    return {
        "week_start": monday.isoformat(),
        "appointments": [{"id": str(r["id"]), "patient": r["full_name"], "mode": r["mode"],
                          "starts_at": r["starts_at"].astimezone(TZ).isoformat()} for r in rows],
    }


@router.get("/requests")
def requests_(dz=Depends(current_dietitian), conn=Depends(get_conn)):
    rows = conn.execute(
        """select a.id, a.starts_at, a.mode, u.full_name from appointments a
           join users u on u.id = a.patient_id
           where a.dietitian_id = %s and a.status = 'pending' and a.starts_at > now() order by a.starts_at""",
        (dz["dietitian_id"],),
    ).fetchall()
    return [{"id": str(r["id"]), "patient": r["full_name"], "initials": _initials(r["full_name"]),
             "mode": r["mode"], "starts_at": r["starts_at"].astimezone(TZ).isoformat()} for r in rows]


class Decision(BaseModel):
    accept: bool


@router.post("/appointments/{appt_id}/decision")
def decide(appt_id: uuid.UUID, body: Decision, dz=Depends(current_dietitian), conn=Depends(get_conn)):
    row = conn.execute(
        """select a.id, a.patient_id, a.starts_at, u.phone from appointments a join users u on u.id = a.patient_id
           where a.id = %s and a.dietitian_id = %s and a.status = 'pending' for update of a""",
        (appt_id, dz["dietitian_id"]),
    ).fetchone()
    if row is None:
        raise HTTPException(404, "Demande introuvable ou déjà traitée")
    status = "confirmed" if body.accept else "refused"
    conn.execute("update appointments set status = %s where id = %s", (status, appt_id))
    when = row["starts_at"].astimezone(TZ)
    if body.accept:
        sms = f"Tchihali : votre rendez-vous du {when:%d/%m à %H:%M} est confirmé."
    else:
        # Créneau libéré (l'index unique ne couvre que pending/confirmed) ; paiement à rembourser.
        conn.execute("update payments set status = 'refunded' where appointment_id = %s and status = 'paid'", (appt_id,))
        sms = f"Tchihali : votre demande du {when:%d/%m à %H:%M} n'a pas pu être acceptée. Choisissez un autre créneau."
    notify(conn, row["patient_id"], "appointment_confirmed" if body.accept else "appointment_refused",
           {"starts_at": when.isoformat(), "dietitian": dz["dietitian_name"]})
    get_sms().send(row["phone"], sms)  # « patient prévenu par SMS »
    audit(conn, dz["id"], "decide", "appointment")
    return {"id": str(appt_id), "status": status}


# ---------- Disponibilités ----------
class SlotIn(BaseModel):
    weekday: int = Field(ge=1, le=7)
    start_time: time


@router.get("/availability")
def get_availability(dz=Depends(current_dietitian), conn=Depends(get_conn)):
    rows = conn.execute(
        "select weekday, to_char(start_time, 'HH24:MI') as t from availability where dietitian_id = %s order by 1, 2",
        (dz["dietitian_id"],),
    ).fetchall()
    return [{"weekday": r["weekday"], "start_time": r["t"]} for r in rows]


@router.post("/availability", status_code=201)
def add_slot(body: SlotIn, dz=Depends(current_dietitian), conn=Depends(get_conn)):
    conn.execute(
        "insert into availability (dietitian_id, weekday, start_time) values (%s, %s, %s) on conflict do nothing",
        (dz["dietitian_id"], body.weekday, body.start_time),
    )
    return {"weekday": body.weekday, "start_time": body.start_time.strftime("%H:%M")}


@router.delete("/availability", status_code=204)
def remove_slot(weekday: int = Query(ge=1, le=7), start_time: time = Query(...),
                dz=Depends(current_dietitian), conn=Depends(get_conn)):
    conn.execute("delete from availability where dietitian_id = %s and weekday = %s and start_time = %s",
                 (dz["dietitian_id"], weekday, start_time))


# ---------- Patients ----------
_PATIENTS_SQL = """
select u.id, u.full_name, u.phone,
       (select min(a.starts_at) from appointments a where a.patient_id = u.id and a.dietitian_id = %s) as since
from users u where u.role = 'patient' and (
  exists (select 1 from appointments a where a.patient_id = u.id and a.dietitian_id = %s)
  or exists (select 1 from messages m where m.patient_id = u.id and m.dietitian_id = %s))
order by u.full_name
"""


@router.get("/patients")
def patients(dz=Depends(current_dietitian), conn=Depends(get_conn)):
    d = dz["dietitian_id"]
    rows = conn.execute(_PATIENTS_SQL, (d, d, d)).fetchall()
    return [{"id": str(r["id"]), "name": r["full_name"], "initials": _initials(r["full_name"]),
             "since": r["since"].astimezone(TZ).date().isoformat() if r["since"] else None} for r in rows]


@router.get("/patients/{patient_id}")
def patient(patient_id: uuid.UUID, dz=Depends(current_dietitian), conn=Depends(get_conn)):
    p = require_linked_patient(conn, dz["dietitian_id"], patient_id)
    h = conn.execute("select conditions, allergies, height_cm, birth_year, goal_weight_kg from health_profiles where user_id = %s",
                     (patient_id,)).fetchone() or {}
    ms = conn.execute("select measured_on, weight_kg, waist_cm, glucose_gl from measurements where patient_id = %s order by measured_on",
                      (patient_id,)).fetchall()

    def kpi(col):
        vals = [float(r[col]) for r in ms if r[col] is not None]
        return None if not vals else {"value": vals[-1], "delta": round(vals[-1] - vals[0], 2)}

    meals = conn.execute(
        """select name, kcal, eaten_at, (eaten_at at time zone 'Africa/Douala')::time as local_time
           from meals where patient_id = %s order by eaten_at desc limit 3""", (patient_id,)).fetchall()
    note = conn.execute("select body from patient_notes where patient_id = %s and dietitian_id = %s",
                        (patient_id, dz["dietitian_id"])).fetchone()
    first = conn.execute("select min(starts_at) as s from appointments where patient_id = %s and dietitian_id = %s",
                         (patient_id, dz["dietitian_id"])).fetchone()["s"]
    audit(conn, dz["id"], "read", "patient")
    return {
        "id": str(patient_id), "name": p["full_name"], "initials": _initials(p["full_name"]),
        "age": (date.today().year - h["birth_year"]) if h.get("birth_year") else None,
        "height_cm": h.get("height_cm"), "goal_weight_kg": _num(h.get("goal_weight_kg")),
        "conditions": h.get("conditions", []), "allergies": h.get("allergies", []),
        "since": first.astimezone(TZ).date().isoformat() if first else None,
        "kpis": {"weight": kpi("weight_kg"), "waist": kpi("waist_cm"), "glucose": kpi("glucose_gl")},
        "weight_series": [{"date": r["measured_on"].isoformat(), "value": float(r["weight_kg"])} for r in ms if r["weight_kg"] is not None],
        "meals": [{"name": m["name"], "kcal": m["kcal"], "eaten_at": m["eaten_at"].astimezone(TZ).isoformat(),
                   "late": m["local_time"] >= time(21, 0) or m["local_time"] < time(5, 0)} for m in meals],
        "note": note["body"] if note else "",
    }


class NoteIn(BaseModel):
    body: str = Field(max_length=4000)


@router.put("/patients/{patient_id}/note")
def put_note(patient_id: uuid.UUID, body: NoteIn, dz=Depends(current_dietitian), conn=Depends(get_conn)):
    require_linked_patient(conn, dz["dietitian_id"], patient_id)
    conn.execute(
        """insert into patient_notes (patient_id, dietitian_id, body) values (%s, %s, %s)
           on conflict (patient_id, dietitian_id) do update set body = excluded.body, updated_at = now()""",
        (patient_id, dz["dietitian_id"], body.body),
    )
    audit(conn, dz["id"], "write", "patient_note")
    return {"body": body.body}


# ---------- Compte rendu ----------
class GoalIn(BaseModel):
    text: str = Field(max_length=200)
    done: bool = True


class MealIn(BaseModel):
    text: str = Field(default="", max_length=200)
    kcal: int = Field(default=0, ge=0, le=3000)


class DayPlan(BaseModel):
    meals: list[MealIn] = Field(max_length=8)


class Measures(BaseModel):
    weight_kg: float | None = Field(default=None, ge=20, le=400)
    waist_cm: float | None = Field(default=None, ge=30, le=300)
    glucose_gl: float | None = Field(default=None, ge=0.2, le=9)


class ReportIn(BaseModel):
    summary: str = Field(default="", max_length=4000)
    goals: list[GoalIn] = Field(default_factory=list, max_length=10)
    plan: list[DayPlan] = Field(default_factory=list, max_length=7)
    measures: Measures = Measures()

    @field_validator("plan")
    @classmethod
    def _seven(cls, v):
        return v + [DayPlan(meals=[]) for _ in range(7 - len(v))]


def _report_json(r: dict) -> dict:
    return {"id": str(r["id"]), "patient_id": str(r["patient_id"]), "session_no": r["session_no"],
            "held_on": r["held_on"].isoformat(), "mode": r["mode"], "summary": r["summary"],
            "goals": r["goals"], "plan": r["plan"], "measures": r["measures"], "status": r["status"],
            "updated_at": r["updated_at"].astimezone(TZ).isoformat()}


@router.get("/reports/{patient_id}")
def get_report(patient_id: uuid.UUID, dz=Depends(current_dietitian), conn=Depends(get_conn)):
    """Brouillon en cours, ou nouveau compte rendu prérempli (numéro de séance suivant)."""
    p = require_linked_patient(conn, dz["dietitian_id"], patient_id)
    d = dz["dietitian_id"]
    row = conn.execute("select * from reports where patient_id = %s and dietitian_id = %s and status = 'draft'",
                       (patient_id, d)).fetchone()
    if row is None:
        n = conn.execute("select coalesce(max(session_no), 0) + 1 as n from reports where patient_id = %s and dietitian_id = %s",
                         (patient_id, d)).fetchone()["n"]
        mode = conn.execute("select mode from appointments where patient_id = %s and dietitian_id = %s order by starts_at desc limit 1",
                            (patient_id, d)).fetchone()
        empty_plan = [{"meals": [{"text": "", "kcal": 0} for _ in range(4)]} for _ in range(7)]
        row = conn.execute(
            """insert into reports (patient_id, dietitian_id, session_no, held_on, mode, plan)
               values (%s, %s, %s, %s, %s, %s) returning *""",
            (patient_id, d, n, datetime.now(TZ).date(), mode["mode"] if mode else "video", json.dumps(empty_plan)),
        ).fetchone()
    audit(conn, dz["id"], "read", "report")
    return {**_report_json(row), "patient_name": p["full_name"]}


@router.put("/reports/{patient_id}")
def save_report(patient_id: uuid.UUID, body: ReportIn, dz=Depends(current_dietitian), conn=Depends(get_conn)):
    """Enregistrement du brouillon (appelé à chaque modification)."""
    require_linked_patient(conn, dz["dietitian_id"], patient_id)
    row = conn.execute(
        """update reports set summary = %s, goals = %s, plan = %s, measures = %s, updated_at = now()
           where patient_id = %s and dietitian_id = %s and status = 'draft' returning *""",
        (body.summary, json.dumps([g.model_dump() for g in body.goals]),
         json.dumps([d.model_dump() for d in body.plan]), json.dumps(body.measures.model_dump(exclude_none=True)),
         patient_id, dz["dietitian_id"]),
    ).fetchone()
    if row is None:
        raise HTTPException(409, "Aucun brouillon en cours : rouvrez le compte rendu")
    return _report_json(row)


@router.post("/reports/{patient_id}/send")
def send_report(patient_id: uuid.UUID, dz=Depends(current_dietitian), conn=Depends(get_conn)):
    p = require_linked_patient(conn, dz["dietitian_id"], patient_id)
    r = conn.execute("select * from reports where patient_id = %s and dietitian_id = %s and status = 'draft' for update",
                     (patient_id, dz["dietitian_id"])).fetchone()
    if r is None:
        raise HTTPException(409, "Aucun brouillon à envoyer")
    if not r["summary"].strip():
        raise HTTPException(422, "Le résumé (« Ce qu'il faut retenir ») est vide")
    m = r["measures"] or {}
    if m:  # les mesures du jour alimentent la courbe de progrès
        conn.execute(
            """insert into measurements (patient_id, measured_on, weight_kg, waist_cm, glucose_gl) values (%s, %s, %s, %s, %s)
               on conflict (patient_id, measured_on) do update set
                 weight_kg = coalesce(excluded.weight_kg, measurements.weight_kg),
                 waist_cm = coalesce(excluded.waist_cm, measurements.waist_cm),
                 glucose_gl = coalesce(excluded.glucose_gl, measurements.glucose_gl)""",
            (patient_id, r["held_on"], m.get("weight_kg"), m.get("waist_cm"), m.get("glucose_gl")),
        )
    pdf = report_pdf(patient=p["full_name"], dietitian=dz["dietitian_name"], session_no=r["session_no"],
                     held_on=r["held_on"].strftime("%d/%m/%Y"), summary=r["summary"], goals=r["goals"],
                     plan=r["plan"], labels=LABELS, days=DAYS)
    fid = save_bytes(conn, patient_id, "document", "application/pdf", pdf)
    conn.execute("insert into documents (patient_id, name, meta, file_id) values (%s, %s, %s, %s)",
                 (patient_id, f"Compte rendu séance {r['session_no']}", r["held_on"].strftime("%d/%m/%Y"), fid))
    now = datetime.now(UTC)
    conn.execute("update reports set status = 'sent', sent_at = %s, updated_at = %s where id = %s", (now, now, r["id"]))
    notify(conn, patient_id, "report_sent", {"session_no": r["session_no"], "dietitian": dz["dietitian_name"]})
    audit(conn, dz["id"], "send", "report")
    return {"status": "sent", "sent_at": now.astimezone(TZ).isoformat()}


# ---------- Messages ----------
class ProMessage(BaseModel):
    patient_id: uuid.UUID
    body: str = Field(min_length=1, max_length=2000)

    @field_validator("body")
    @classmethod
    def _strip(cls, v):
        v = v.strip()
        if not v:
            raise ValueError("Message vide")
        return v


@router.get("/conversations")
def conversations(dz=Depends(current_dietitian), conn=Depends(get_conn)):
    rows = conn.execute(
        """select distinct on (m.patient_id) m.patient_id, u.full_name, m.body, m.created_at, m.sender_id = m.patient_id as from_patient
           from messages m join users u on u.id = m.patient_id
           where m.dietitian_id = %s order by m.patient_id, m.id desc""", (dz["dietitian_id"],)).fetchall()
    rows.sort(key=lambda r: r["created_at"], reverse=True)
    return [{"patient_id": str(r["patient_id"]), "patient": r["full_name"], "last": r["body"],
             "at": r["created_at"].isoformat(), "from_patient": r["from_patient"]} for r in rows]


@router.get("/messages")
def pro_messages(patient_id: uuid.UUID, after_id: int = Query(default=0, ge=0),
                 dz=Depends(current_dietitian), conn=Depends(get_conn)):
    require_linked_patient(conn, dz["dietitian_id"], patient_id)
    rows = conn.execute(
        """select id, body, file_id, created_at, (sender_id = %s) as from_me from messages
           where patient_id = %s and dietitian_id = %s and id > %s order by id limit 200""",
        (dz["id"], patient_id, dz["dietitian_id"], after_id)).fetchall()
    audit(conn, dz["id"], "read", "messages")
    return [{"id": r["id"], "from_me": r["from_me"], "body": r["body"],
             "photo_file_id": str(r["file_id"]) if r["file_id"] else None,
             "created_at": r["created_at"].isoformat()} for r in rows]


@router.post("/messages", status_code=201)
def pro_send(body: ProMessage, dz=Depends(current_dietitian), conn=Depends(get_conn)):
    require_linked_patient(conn, dz["dietitian_id"], body.patient_id)
    row = conn.execute(
        """insert into messages (patient_id, dietitian_id, sender_id, body) values (%s, %s, %s, %s)
           returning id, body, created_at""", (body.patient_id, dz["dietitian_id"], dz["id"], body.body)).fetchone()
    notify(conn, body.patient_id, "new_message", {"dietitian": dz["dietitian_name"]})
    return {"id": row["id"], "from_me": True, "body": row["body"], "photo_file_id": None,
            "created_at": row["created_at"].isoformat()}
