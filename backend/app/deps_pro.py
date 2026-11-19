from fastapi import Depends, HTTPException, status

from .db import get_conn
from .deps import current_user


def current_dietitian(user=Depends(current_user), conn=Depends(get_conn)) -> dict:
    """Utilisateur connecté qui est un diététicien : renvoie {user..., dietitian_id, dietitian_name}."""
    if user["role"] != "dietitian":
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Réservé aux diététiciens")
    d = conn.execute("select id, name from dietitians where user_id = %s", (user["id"],)).fetchone()
    if d is None:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Profil diététicien introuvable")
    return {**user, "dietitian_id": d["id"], "dietitian_name": d["name"]}


def require_linked_patient(conn, dietitian_id: str, patient_id) -> dict:
    """Un diététicien n'accède qu'aux patients avec qui il a un rendez-vous ou une conversation."""
    row = conn.execute(
        """select u.id, u.full_name, u.phone from users u
           where u.id = %s and u.role = 'patient' and (
             exists (select 1 from appointments a where a.patient_id = u.id and a.dietitian_id = %s)
             or exists (select 1 from messages m where m.patient_id = u.id and m.dietitian_id = %s))""",
        (patient_id, dietitian_id, dietitian_id),
    ).fetchone()
    if row is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Patient introuvable")
    return row
