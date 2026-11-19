from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field, field_validator

from ..db import audit, get_conn
from ..deps import current_user

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
