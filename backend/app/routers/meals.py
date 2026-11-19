import uuid
from datetime import UTC, date, datetime, timedelta
from typing import Literal
from zoneinfo import ZoneInfo

from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel, Field, field_validator

from ..config import settings
from ..db import audit, get_conn
from ..deps import current_user

router = APIRouter(tags=["journal"])
TZ = ZoneInfo("Africa/Douala")
MEAL_TYPES = ("breakfast", "lunch", "snack", "dinner")


class NewMeal(BaseModel):
    eaten_at: datetime | None = None
    meal_type: Literal["breakfast", "lunch", "snack", "dinner"]
    name: str = Field(min_length=1, max_length=120)
    kcal: int = Field(ge=0, le=5000)
    protein: int = Field(default=0, ge=0, le=500)
    carbs: int = Field(default=0, ge=0, le=1000)
    fat: int = Field(default=0, ge=0, le=500)
    photo_file_id: uuid.UUID | None = None

    @field_validator("name")
    @classmethod
    def _strip(cls, v):
        v = v.strip()
        if not v:
            raise ValueError("Nom vide")
        return v


class MealFeeling(BaseModel):
    mood: int | None = Field(default=None, ge=0, le=4)
    symptoms: list[int] = Field(default_factory=list, max_length=6)

    @field_validator("symptoms")
    @classmethod
    def _range(cls, v):
        if any(not 0 <= i <= 3 for i in v):
            raise ValueError("valeur hors liste")
        return sorted(set(v))


class GoalsBody(BaseModel):
    day: date
    done: list[int] = Field(default_factory=list, max_length=3)

    @field_validator("done")
    @classmethod
    def _range(cls, v):
        if any(not 0 <= i <= 2 for i in v):
            raise ValueError("objectif inconnu")
        return sorted(set(v))


def _meal(r: dict) -> dict:
    return {
        "id": str(r["id"]),
        "eaten_at": r["eaten_at"].isoformat(),
        "meal_type": r["meal_type"],
        "name": r["name"],
        "kcal": r["kcal"], "protein": r["protein"], "carbs": r["carbs"], "fat": r["fat"],
        "photo_file_id": str(r["photo_file_id"]) if r["photo_file_id"] else None,
        "mood": r["mood"],
        "symptoms": r["symptoms"],
    }


def _bounds(day: date) -> tuple[datetime, datetime]:
    start = datetime(day.year, day.month, day.day, tzinfo=TZ)
    return start, start + timedelta(days=1)


@router.get("/meals")
def list_meals(day: date = Query(...), user=Depends(current_user), conn=Depends(get_conn)):
    start, end = _bounds(day)
    rows = conn.execute(
        "select * from meals where patient_id = %s and eaten_at >= %s and eaten_at < %s order by eaten_at",
        (user["id"], start, end),
    ).fetchall()
    audit(conn, user["id"], "read", "meals")
    return {
        "meals": [_meal(r) for r in rows],
        "total_kcal": sum(r["kcal"] for r in rows),
        "target_kcal": settings.daily_kcal_target,
    }


@router.post("/meals", status_code=201)
def add_meal(body: NewMeal, user=Depends(current_user), conn=Depends(get_conn)):
    eaten = body.eaten_at or datetime.now(UTC)
    if eaten.tzinfo is None:
        eaten = eaten.replace(tzinfo=TZ)
    if eaten > datetime.now(UTC) + timedelta(hours=1):
        raise HTTPException(400, "Un repas ne peut pas être dans le futur")
    if body.photo_file_id and not conn.execute(
        "select 1 from files where id = %s and owner_id = %s and kind = 'meal_photo'",
        (body.photo_file_id, user["id"]),
    ).fetchone():
        raise HTTPException(400, "Photo introuvable")
    row = conn.execute(
        """insert into meals (patient_id, eaten_at, meal_type, name, kcal, protein, carbs, fat, photo_file_id)
           values (%s, %s, %s, %s, %s, %s, %s, %s, %s) returning *""",
        (user["id"], eaten, body.meal_type, body.name, body.kcal, body.protein, body.carbs, body.fat,
         body.photo_file_id),
    ).fetchone()
    audit(conn, user["id"], "create", "meal")
    return _meal(row)


@router.patch("/meals/{meal_id}")
def set_feeling(meal_id: uuid.UUID, body: MealFeeling, user=Depends(current_user), conn=Depends(get_conn)):
    row = conn.execute(
        "update meals set mood = %s, symptoms = %s where id = %s and patient_id = %s returning *",
        (body.mood, body.symptoms, meal_id, user["id"]),
    ).fetchone()
    if row is None:
        raise HTTPException(404, "Repas introuvable")
    return _meal(row)


@router.delete("/meals/{meal_id}", status_code=204)
def delete_meal(meal_id: uuid.UUID, user=Depends(current_user), conn=Depends(get_conn)):
    n = conn.execute("delete from meals where id = %s and patient_id = %s", (meal_id, user["id"])).rowcount
    if n == 0:
        raise HTTPException(404, "Repas introuvable")
    audit(conn, user["id"], "delete", "meal")


@router.get("/goals")
def get_goals(day: date = Query(...), user=Depends(current_user), conn=Depends(get_conn)):
    row = conn.execute(
        "select done from daily_goals where patient_id = %s and day = %s", (user["id"], day)
    ).fetchone()
    return {"day": day.isoformat(), "done": row["done"] if row else []}


@router.put("/goals")
def put_goals(body: GoalsBody, user=Depends(current_user), conn=Depends(get_conn)):
    conn.execute(
        """insert into daily_goals (patient_id, day, done) values (%s, %s, %s)
           on conflict (patient_id, day) do update set done = excluded.done""",
        (user["id"], body.day, body.done),
    )
    return {"day": body.day.isoformat(), "done": body.done}
