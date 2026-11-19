from datetime import date, datetime
from typing import Literal
from zoneinfo import ZoneInfo

import psycopg.errors
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel

from ..config import settings
from ..db import audit, get_conn
from ..deps import current_user
from ..notify import notify
from .dietitians import day_slots

router = APIRouter(prefix="/appointments", tags=["appointments"])
TZ = ZoneInfo("Africa/Douala")
PRICES = {"video": 12000, "office": 15000}  # tarifs FCFA : seul le serveur fait foi


class BookingRequest(BaseModel):
    dietitian_id: str
    day: date
    time: str  # « 10:30 », heure locale Africa/Douala
    mode: Literal["video", "office"]
    method: Literal["orange_money", "mtn_momo", "card"]
    phone: str | None = None  # numéro Mobile Money


def _appt(row: dict) -> dict:
    return {
        "id": str(row["id"]),
        "dietitian_id": row["dietitian_id"],
        "starts_at": row["starts_at"].isoformat(),
        "mode": row["mode"],
        "status": row["status"],
        "price_fcfa": row["price_fcfa"],
    }


@router.post("", status_code=status.HTTP_201_CREATED)
def book(body: BookingRequest, user=Depends(current_user), conn=Depends(get_conn)):
    d = conn.execute("select video, in_person from dietitians where id = %s", (body.dietitian_id,)).fetchone()
    if d is None:
        raise HTTPException(404, "Diététicien introuvable")
    if not (d["video"] if body.mode == "video" else d["in_person"]):
        raise HTTPException(400, "Ce mode de consultation n'est pas proposé")
    if body.method != "card" and not body.phone:
        raise HTTPException(400, "Numéro Mobile Money requis")
    slot = next((s for s in day_slots(conn, body.dietitian_id, body.day) if s["time"] == body.time), None)
    if slot is None:
        raise HTTPException(400, "Créneau indisponible")
    if slot["taken"]:
        raise HTTPException(409, "Ce créneau vient d'être réservé")
    hh, mm = (int(x) for x in body.time.split(":"))
    starts_at = datetime(body.day.year, body.day.month, body.day.day, hh, mm, tzinfo=TZ)
    price = PRICES[body.mode]
    try:
        appt = conn.execute(
            """insert into appointments (patient_id, dietitian_id, starts_at, mode, price_fcfa)
               values (%s, %s, %s, %s, %s) returning *""",
            (user["id"], body.dietitian_id, starts_at, body.mode, price),
        ).fetchone()
    except psycopg.errors.UniqueViolation:
        raise HTTPException(409, "Ce créneau vient d'être réservé") from None
    # Paiement SIMULÉ tant qu'aucun opérateur Mobile Money n'est branché : aucun argent ne bouge.
    conn.execute(
        """insert into payments (appointment_id, method, amount_fcfa, phone, status, provider, provider_ref)
           values (%s, %s, %s, %s, 'paid', %s, %s)""",
        (appt["id"], body.method, price, body.phone, settings.payment_provider, "SIMULATED"),
    )
    audit(conn, user["id"], "create", "appointment")
    owner = conn.execute("select user_id from dietitians where id = %s", (body.dietitian_id,)).fetchone()
    if owner and owner["user_id"]:
        notify(conn, owner["user_id"], "appointment_request",
               {"patient": user["full_name"], "starts_at": starts_at.isoformat()})
    return _appt(appt)


@router.get("/mine")
def mine(user=Depends(current_user), conn=Depends(get_conn)):
    rows = conn.execute(
        "select * from appointments where patient_id = %s order by starts_at desc", (user["id"],)
    ).fetchall()
    return [_appt(r) for r in rows]
