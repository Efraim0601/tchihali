from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel, Field, field_validator

from ..db import audit, get_conn
from ..deps import current_user

router = APIRouter(prefix="/messages", tags=["messages"])


class NewMessage(BaseModel):
    dietitian_id: str
    body: str = Field(min_length=1, max_length=2000)

    @field_validator("body")
    @classmethod
    def _strip(cls, v):
        v = v.strip()
        if not v:
            raise ValueError("Message vide")
        return v


def _msg(r: dict) -> dict:
    return {
        "id": r["id"],
        "from_me": r["from_me"],
        "body": r["body"],
        "created_at": r["created_at"].isoformat(),
    }


def _require_patient(user: dict) -> None:
    # Les échanges côté diététicien (espace praticien) seront ajoutés avec ses propres règles d'accès.
    if user["role"] != "patient":
        raise HTTPException(403, "Réservé aux patients")


@router.get("")
def list_messages(
    dietitian_id: str,
    after_id: int = Query(default=0, ge=0),
    user=Depends(current_user),
    conn=Depends(get_conn),
):
    _require_patient(user)
    rows = conn.execute(
        """select id, body, created_at, (sender_id = %s) as from_me from messages
           where patient_id = %s and dietitian_id = %s and id > %s order by id limit 200""",
        (user["id"], user["id"], dietitian_id, after_id),
    ).fetchall()
    audit(conn, user["id"], "read", "messages")
    return [_msg(r) for r in rows]


@router.post("", status_code=201)
def send_message(body: NewMessage, user=Depends(current_user), conn=Depends(get_conn)):
    _require_patient(user)
    if not conn.execute("select 1 from dietitians where id = %s", (body.dietitian_id,)).fetchone():
        raise HTTPException(404, "Diététicien introuvable")
    row = conn.execute(
        """insert into messages (patient_id, dietitian_id, sender_id, body) values (%s, %s, %s, %s)
           returning id, body, created_at, true as from_me""",
        (user["id"], body.dietitian_id, user["id"], body.body),
    ).fetchone()
    return _msg(row)
