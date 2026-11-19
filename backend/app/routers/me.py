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
        "select goal, conditions, allergies from health_profiles where user_id = %s", (user["id"],)
    ).fetchone()
    audit(conn, user["id"], "read", "health_profile")
    return row or {"goal": None, "conditions": [], "allergies": []}


@router.put("/health")
def put_health(body: Health, user=Depends(current_user), conn=Depends(get_conn)):
    conn.execute(
        """insert into health_profiles (user_id, goal, conditions, allergies) values (%s, %s, %s, %s)
           on conflict (user_id) do update set goal = excluded.goal, conditions = excluded.conditions,
             allergies = excluded.allergies, updated_at = now()""",
        (user["id"], body.goal, body.conditions, body.allergies),
    )
    audit(conn, user["id"], "write", "health_profile")
    return body
