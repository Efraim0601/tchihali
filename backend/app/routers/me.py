from datetime import UTC, datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field, field_validator

from ..db import audit, get_conn
from ..deps import current_user
from .files import files_root

router = APIRouter(prefix="/me", tags=["me"])


class ProfileUpdate(BaseModel):
    full_name: str = Field(min_length=1, max_length=120)

    @field_validator("full_name")
    @classmethod
    def _strip(cls, v):
        return v.strip()


class Health(BaseModel):
    goal: int | None = Field(default=None, ge=0, le=3)
    conditions: list[int] = Field(default_factory=list, max_length=8)
    allergies: list[int] = Field(default_factory=list, max_length=8)
    height_cm: int | None = Field(default=None, ge=80, le=250)
    birth_year: int | None = Field(default=None, ge=1900, le=2100)
    goal_weight_kg: float | None = Field(default=None, ge=30, le=300)

    @field_validator("conditions", "allergies")
    @classmethod
    def _range(cls, v):
        if any(not 0 <= i <= 3 for i in v):
            raise ValueError("valeur hors liste")
        return sorted(set(v))


@router.get("")
def get_me(user=Depends(current_user)):
    return {"id": str(user["id"]), "phone": user["phone"], "full_name": user["full_name"], "role": user["role"]}


@router.patch("")
def update_me(body: ProfileUpdate, user=Depends(current_user), conn=Depends(get_conn)):
    conn.execute("update users set full_name = %s where id = %s", (body.full_name, user["id"]))
    return {"id": str(user["id"]), "phone": user["phone"], "full_name": body.full_name, "role": user["role"]}


@router.get("/health")
def get_health(user=Depends(current_user), conn=Depends(get_conn)):
    row = conn.execute(
        "select goal, conditions, allergies, height_cm, birth_year, goal_weight_kg "
        "from health_profiles where user_id = %s", (user["id"],)
    ).fetchone()
    audit(conn, user["id"], "read", "health_profile")
    if row and row["goal_weight_kg"] is not None:
        row["goal_weight_kg"] = float(row["goal_weight_kg"])
    return row or {"goal": None, "conditions": [], "allergies": [], "height_cm": None,
                   "birth_year": None, "goal_weight_kg": None}


@router.put("/health")
def put_health(body: Health, user=Depends(current_user), conn=Depends(get_conn)):
    conn.execute(
        """insert into health_profiles (user_id, goal, conditions, allergies, height_cm, birth_year, goal_weight_kg)
           values (%s, %s, %s, %s, %s, %s, %s)
           on conflict (user_id) do update set goal = excluded.goal, conditions = excluded.conditions,
             allergies = excluded.allergies,
             height_cm = coalesce(excluded.height_cm, health_profiles.height_cm),
             birth_year = coalesce(excluded.birth_year, health_profiles.birth_year),
             goal_weight_kg = coalesce(excluded.goal_weight_kg, health_profiles.goal_weight_kg),
             updated_at = now()""",
        (user["id"], body.goal, body.conditions, body.allergies, body.height_cm, body.birth_year,
         body.goal_weight_kg),
    )
    audit(conn, user["id"], "write", "health_profile")
    return body


# ---------- Droits du patient : export et suppression ----------
def _rows(conn, sql: str, params: tuple) -> list[dict]:
    return conn.execute(sql, params).fetchall()


@router.get("/export")
def export_data(user=Depends(current_user), conn=Depends(get_conn)):
    """Toutes les données du patient, dans un fichier lisible (droit d'accès / portabilité)."""
    uid = (user["id"],)
    data = {
        "exported_at": datetime.now(UTC).isoformat(),
        "profile": _rows(conn, "select id, phone, full_name, role, created_at, terms_accepted_at, terms_version from users where id = %s", uid),
        "health": _rows(conn, "select goal, conditions, allergies, height_cm, birth_year, goal_weight_kg, updated_at from health_profiles where user_id = %s", uid),
        "meals": _rows(conn, "select eaten_at, meal_type, name, kcal, protein, carbs, fat, mood, symptoms, photo_file_id from meals where patient_id = %s order by eaten_at", uid),
        "daily_goals": _rows(conn, "select day, done from daily_goals where patient_id = %s order by day", uid),
        "measurements": _rows(conn, "select measured_on, weight_kg, waist_cm, glucose_gl from measurements where patient_id = %s order by measured_on", uid),
        "appointments": _rows(conn, "select a.starts_at, a.mode, a.status, a.price_fcfa, d.name as dietitian from appointments a join dietitians d on d.id = a.dietitian_id where a.patient_id = %s order by a.starts_at", uid),
        "payments": _rows(conn, "select p.method, p.amount_fcfa, p.status, p.created_at from payments p join appointments a on a.id = p.appointment_id where a.patient_id = %s order by p.created_at", uid),
        "messages": _rows(conn, "select created_at, (sender_id = patient_id) as sent_by_me, body, file_id from messages where patient_id = %s order by id", uid),
        "reports": _rows(conn, "select session_no, held_on, summary, goals, plan, measures, sent_at from reports where patient_id = %s and status = 'sent' order by held_on", uid),
        "documents": _rows(conn, "select name, meta, created_at from documents where patient_id = %s order by created_at", uid),
        "notifications": _rows(conn, "select kind, data, created_at from notifications where user_id = %s order by id", uid),
    }
    audit(conn, user["id"], "export", "account")
    # JSONResponse gère dates, UUID et Decimal ; le téléchargement s'appelle tchihali-donnees.json.
    return JSONResponse(jsonable_encoder(data), headers={"Content-Disposition": 'attachment; filename="tchihali-donnees.json"', "Cache-Control": "no-store"})


@router.delete("", status_code=204)
def delete_account(confirm: str = Query(default=""), user=Depends(current_user), conn=Depends(get_conn)):
    """Suppression définitive du compte patient et de toutes ses données (droit à l'effacement)."""
    if confirm != "yes":
        raise HTTPException(400, "Confirmation requise (confirm=yes)")
    if user["role"] != "patient":
        raise HTTPException(403, "Les comptes diététiciens se suppriment via l'administration")
    uid = user["id"]
    paths = [r["path"] for r in conn.execute("select path from files where owner_id = %s", (uid,)).fetchall()]
    conn.execute("delete from payments where appointment_id in (select id from appointments where patient_id = %s)", (uid,))
    conn.execute("delete from appointments where patient_id = %s", (uid,))
    conn.execute("delete from messages where patient_id = %s or sender_id = %s", (uid, uid))
    conn.execute("delete from patient_notes where patient_id = %s", (uid,))
    conn.execute("delete from documents where patient_id = %s", (uid,))
    conn.execute("update meals set photo_file_id = null where patient_id = %s", (uid,))
    conn.execute("delete from files where owner_id = %s", (uid,))
    conn.execute("delete from users where id = %s", (uid,))  # le reste part en cascade
    # Trace minimale de l'effacement, sans donnée personnelle (journal d'accès).
    audit(conn, None, "delete_account", str(uid))
    for p in paths:
        (files_root() / p).unlink(missing_ok=True)
