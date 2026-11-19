import uuid
from datetime import datetime
from zoneinfo import ZoneInfo

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import FileResponse

from ..db import audit, get_conn
from ..deps import current_user
from .files import files_root

router = APIRouter(tags=["record"])
TZ = ZoneInfo("Africa/Douala")


@router.get("/record")
def record(user=Depends(current_user), conn=Depends(get_conn)):
    """Carnet de suivi : dernière séance envoyée, plan du jour, documents."""
    rep = conn.execute(
        """select r.*, d.name as dietitian_name from reports r join dietitians d on d.id = r.dietitian_id
           where r.patient_id = %s and r.status = 'sent' order by r.held_on desc, r.sent_at desc limit 1""",
        (user["id"],),
    ).fetchone()
    session = plan = None
    if rep:
        session = {
            "session_no": rep["session_no"], "held_on": rep["held_on"].isoformat(), "mode": rep["mode"],
            "dietitian": rep["dietitian_name"], "summary": rep["summary"], "goals": rep["goals"],
        }
        days = rep["plan"] or []
        wd = datetime.now(TZ).weekday()  # 0 = lundi
        plan = (days[wd] if wd < len(days) else {"meals": []}).get("meals", [])
    docs = conn.execute(
        "select id, name, meta, file_id, created_at from documents where patient_id = %s order by created_at desc",
        (user["id"],),
    ).fetchall()
    audit(conn, user["id"], "read", "record")
    return {
        "session": session,
        "plan": plan,
        "documents": [{"id": str(d["id"]), "name": d["name"], "meta": d["meta"],
                       "downloadable": d["file_id"] is not None} for d in docs],
    }


@router.get("/documents/{doc_id}/download")
def download_document(doc_id: uuid.UUID, user=Depends(current_user), conn=Depends(get_conn)):
    row = conn.execute(
        """select d.name, f.path, f.content_type from documents d join files f on f.id = d.file_id
           where d.id = %s and d.patient_id = %s""",
        (doc_id, user["id"]),
    ).fetchone()
    if row is None:
        raise HTTPException(404, "Document introuvable")
    audit(conn, user["id"], "read", "document")
    safe = "".join(c for c in row["name"] if c.isalnum() or c in " ._-")[:80] or "document"
    return FileResponse(files_root() / row["path"], media_type=row["content_type"],
                        filename=f"{safe}.pdf", headers={"X-Content-Type-Options": "nosniff"})
