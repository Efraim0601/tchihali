from datetime import date, timedelta

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field, model_validator

from ..db import audit, get_conn
from ..deps import current_user

router = APIRouter(tags=["progress"])


class NewMeasurement(BaseModel):
    measured_on: date
    weight_kg: float | None = Field(default=None, ge=20, le=400)
    waist_cm: float | None = Field(default=None, ge=30, le=300)
    glucose_gl: float | None = Field(default=None, ge=0.2, le=9)

    @model_validator(mode="after")
    def _one(self):
        if self.weight_kg is None and self.waist_cm is None and self.glucose_gl is None:
            raise ValueError("Au moins une mesure est requise")
        if self.measured_on > date.today() + timedelta(days=1):
            raise ValueError("Date dans le futur")
        return self


def _f(v):
    return None if v is None else float(v)


@router.post("/measurements", status_code=201)
def add_measurement(body: NewMeasurement, user=Depends(current_user), conn=Depends(get_conn)):
    row = conn.execute(
        """insert into measurements (patient_id, measured_on, weight_kg, waist_cm, glucose_gl)
           values (%s, %s, %s, %s, %s)
           on conflict (patient_id, measured_on) do update set
             weight_kg = coalesce(excluded.weight_kg, measurements.weight_kg),
             waist_cm = coalesce(excluded.waist_cm, measurements.waist_cm),
             glucose_gl = coalesce(excluded.glucose_gl, measurements.glucose_gl)
           returning measured_on, weight_kg, waist_cm, glucose_gl""",
        (user["id"], body.measured_on, body.weight_kg, body.waist_cm, body.glucose_gl),
    ).fetchone()
    audit(conn, user["id"], "write", "measurement")
    return {"measured_on": row["measured_on"].isoformat(), "weight_kg": _f(row["weight_kg"]),
            "waist_cm": _f(row["waist_cm"]), "glucose_gl": _f(row["glucose_gl"])}


def streak_days(conn, patient_id) -> int:
    """Plus longue série de jours consécutifs avec au moins un repas dans le journal."""
    days = [
        r["d"]
        for r in conn.execute(
            """select distinct (eaten_at at time zone 'Africa/Douala')::date as d
               from meals where patient_id = %s order by d""",
            (patient_id,),
        ).fetchall()
    ]
    best = run = 0
    prev = None
    for d in days:
        run = run + 1 if prev is not None and d - prev == timedelta(days=1) else 1
        best = max(best, run)
        prev = d
    return best


def build_progress(conn, patient_id) -> dict:
    rows = conn.execute(
        "select measured_on, weight_kg, waist_cm, glucose_gl from measurements "
        "where patient_id = %s order by measured_on", (patient_id,)
    ).fetchall()
    health = conn.execute(
        "select height_cm, goal_weight_kg from health_profiles where user_id = %s", (patient_id,)
    ).fetchone() or {}
    height = health.get("height_cm")
    weight = [{"date": r["measured_on"].isoformat(), "value": float(r["weight_kg"])} for r in rows if r["weight_kg"] is not None]
    waist = [{"date": r["measured_on"].isoformat(), "value": float(r["waist_cm"])} for r in rows if r["waist_cm"] is not None]
    glucose = [{"date": r["measured_on"].isoformat(), "value": float(r["glucose_gl"])} for r in rows if r["glucose_gl"] is not None]
    bmi = [{"date": w["date"], "value": round(w["value"] / ((height / 100) ** 2), 1)} for w in weight] if height else []
    lost = (weight[0]["value"] - weight[-1]["value"]) if len(weight) >= 2 else 0
    first_session = conn.execute(
        "select 1 from reports where patient_id = %s and status = 'sent' limit 1", (patient_id,)
    ).fetchone() is not None
    streak = streak_days(conn, patient_id)
    return {
        "weight": weight, "bmi": bmi, "waist": waist, "glucose": glucose,
        "goal_weight_kg": _f(health.get("goal_weight_kg")),
        "height_cm": height,
        "badges": {"first_session": first_session, "journal_streak_14": streak >= 14,
                   "lost_4kg": lost >= 4, "streak_days": streak, "lost_kg": round(lost, 1)},
    }


@router.get("/progress")
def progress(user=Depends(current_user), conn=Depends(get_conn)):
    audit(conn, user["id"], "read", "progress")
    return build_progress(conn, user["id"])
