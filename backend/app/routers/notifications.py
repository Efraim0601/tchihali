from fastapi import APIRouter, Depends, status

from ..db import get_conn
from ..deps import current_user

router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.get("")
def list_notifications(user=Depends(current_user), conn=Depends(get_conn)):
    rows = conn.execute(
        "select id, kind, title, body, data, created_at, read_at from notifications "
        "where user_id = %s order by id desc limit 50", (user["id"],)
    ).fetchall()
    return {
        "unread": sum(1 for r in rows if r["read_at"] is None),
        "items": [{"id": r["id"], "kind": r["kind"], "title": r["title"], "body": r["body"],
                   "data": r["data"], "created_at": r["created_at"].isoformat(), "read": r["read_at"] is not None} for r in rows],
    }


@router.post("/read-all", status_code=status.HTTP_204_NO_CONTENT)
def read_all(user=Depends(current_user), conn=Depends(get_conn)):
    conn.execute("update notifications set read_at = now() where user_id = %s and read_at is null", (user["id"],))
