import jwt
from fastapi import Depends, Header, HTTPException, status

from .db import get_conn
from .security import decode_access_token


def current_user(authorization: str | None = Header(default=None), conn=Depends(get_conn)) -> dict:
    if not authorization or not authorization.lower().startswith("bearer "):
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Connexion requise")
    try:
        claims = decode_access_token(authorization[7:])
    except jwt.PyJWTError:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Session expirée") from None
    row = conn.execute(
        "select id, phone, full_name, role from users where id = %s", (claims["sub"],)
    ).fetchone()
    if row is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Compte introuvable")
    return row
