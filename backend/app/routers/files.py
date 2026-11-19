import uuid
from pathlib import Path

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from fastapi.responses import FileResponse

from ..config import settings
from ..db import audit, get_conn
from ..deps import current_user

router = APIRouter(prefix="/files", tags=["files"])

# Types acceptés, reconnus par leurs premiers octets (on ne fait pas confiance au type annoncé).
_MAGIC = {
    "image/jpeg": (b"\xff\xd8\xff",),
    "image/png": (b"\x89PNG\r\n\x1a\n",),
    "image/webp": (b"RIFF",),
}


def _sniff(head: bytes) -> str | None:
    for ctype, prefixes in _MAGIC.items():
        if any(head.startswith(p) for p in prefixes):
            if ctype == "image/webp" and head[8:12] != b"WEBP":
                continue
            return ctype
    return None


def files_root() -> Path:
    root = Path(settings.files_dir)
    root.mkdir(parents=True, exist_ok=True)
    return root


def save_bytes(conn, owner_id, kind: str, content_type: str, data: bytes) -> str:
    """Enregistre un fichier sur disque (nom aléatoire) et dans la table `files`."""
    fid = uuid.uuid4()
    (files_root() / str(fid)).write_bytes(data)
    conn.execute(
        "insert into files (id, owner_id, kind, content_type, size_bytes, path) values (%s, %s, %s, %s, %s, %s)",
        (fid, owner_id, kind, content_type, len(data), str(fid)),
    )
    return str(fid)


def can_access(conn, user: dict, f: dict) -> bool:
    if f["owner_id"] == user["id"]:
        return True
    if user["role"] != "dietitian":
        return False
    # Un diététicien accède aux fichiers de ses patients (rendez-vous ou messages en commun).
    return conn.execute(
        """select 1 from dietitians d
           where d.user_id = %s and (
             exists (select 1 from appointments a where a.dietitian_id = d.id and a.patient_id = %s)
             or exists (select 1 from messages m where m.dietitian_id = d.id and m.patient_id = %s))""",
        (user["id"], f["owner_id"], f["owner_id"]),
    ).fetchone() is not None


@router.post("", status_code=201)
async def upload(
    file: UploadFile = File(...),
    kind: str = Form(...),
    user=Depends(current_user),
    conn=Depends(get_conn),
):
    if kind not in ("meal_photo", "chat_photo"):
        raise HTTPException(422, "Type de fichier inconnu")
    limit = settings.max_upload_mb * 1024 * 1024
    data = await file.read(limit + 1)
    if len(data) > limit:
        raise HTTPException(413, f"Fichier trop lourd ({settings.max_upload_mb} Mo maximum)")
    ctype = _sniff(data[:16])
    if ctype is None:
        raise HTTPException(415, "Seules les photos JPEG, PNG ou WebP sont acceptées")
    fid = save_bytes(conn, user["id"], kind, ctype, data)
    return {"id": fid, "content_type": ctype, "size": len(data)}


@router.get("/{file_id}")
def download(file_id: uuid.UUID, user=Depends(current_user), conn=Depends(get_conn)):
    f = conn.execute("select * from files where id = %s", (file_id,)).fetchone()
    if f is None or not can_access(conn, user, f):
        raise HTTPException(404, "Fichier introuvable")  # même réponse : on ne révèle pas l'existence
    audit(conn, user["id"], "read", "file")
    return FileResponse(files_root() / f["path"], media_type=f["content_type"],
                        headers={"Cache-Control": "private, max-age=3600", "X-Content-Type-Options": "nosniff"})
