import hmac
import re
from datetime import UTC, datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, field_validator

from ..config import settings
from ..db import audit, get_conn
from ..security import (
    create_access_token,
    hash_code,
    hash_token,
    new_code,
    new_refresh_token,
)
from ..sms import get_sms

router = APIRouter(prefix="/auth", tags=["auth"])

MAX_CODES_PER_10_MIN = 3
MAX_ATTEMPTS = 5
CODE_TTL = timedelta(minutes=5)


def _normalize_phone(v: str) -> str:
    phone = re.sub(r"[\s.-]", "", v)
    if not re.fullmatch(r"\+\d{8,15}", phone):
        raise ValueError("Numéro invalide : utilisez le format international (+237…)")
    return phone


class CodeRequest(BaseModel):
    phone: str
    name: str | None = None
    terms_version: str | None = None  # version acceptée (obligatoire à la création d'un compte)

    _phone = field_validator("phone")(_normalize_phone)

    @field_validator("name")
    @classmethod
    def _name(cls, v):
        return v.strip()[:120] if v else None


class VerifyRequest(BaseModel):
    phone: str
    code: str

    _phone = field_validator("phone")(_normalize_phone)

    @field_validator("code")
    @classmethod
    def _code(cls, v):
        if not re.fullmatch(r"\d{6}", v):
            raise ValueError("Le code comporte 6 chiffres")
        return v


class RefreshRequest(BaseModel):
    refresh_token: str


def _issue_tokens(conn, user: dict) -> dict:
    refresh = new_refresh_token()
    conn.execute(
        "insert into refresh_tokens (user_id, token_hash, expires_at) values (%s, %s, %s)",
        (user["id"], hash_token(refresh), datetime.now(UTC) + timedelta(days=settings.refresh_ttl_days)),
    )
    return {
        "access_token": create_access_token(str(user["id"]), user["role"]),
        "refresh_token": refresh,
        "user": {
            "id": str(user["id"]),
            "phone": user["phone"],
            "full_name": user["full_name"],
            "role": user["role"],
        },
    }


@router.post("/request-code", status_code=status.HTTP_202_ACCEPTED)
def request_code(body: CodeRequest, conn=Depends(get_conn)):
    recent = conn.execute(
        "select count(*) as n from otp_codes where phone = %s and created_at > now() - interval '10 minutes'",
        (body.phone,),
    ).fetchone()["n"]
    if recent >= MAX_CODES_PER_10_MIN:
        raise HTTPException(status.HTTP_429_TOO_MANY_REQUESTS, "Trop de demandes. Réessayez dans quelques minutes.")
    exists = conn.execute("select 1 from users where phone = %s", (body.phone,)).fetchone() is not None
    if not exists and body.terms_version != settings.terms_version:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY,
                            "Acceptez les conditions d'utilisation pour créer un compte")
    # Code fixe de test : uniquement en développement (refusé au démarrage en production).
    fixed = settings.dev_fixed_code if settings.env == "dev" else ""
    code = fixed if re.fullmatch(r"\d{6}", fixed) else new_code()
    conn.execute(
        "insert into otp_codes (phone, name, code_hash, expires_at, terms_version) values (%s, %s, %s, %s, %s)",
        (body.phone, body.name, hash_code(body.phone, code), datetime.now(UTC) + CODE_TTL, body.terms_version),
    )
    get_sms().send(body.phone, f"Tchihali : votre code est {code}. Il expire dans 5 minutes.")
    # Le code n'est renvoyé qu'en développement, pour tester sans SMS.
    return {"sent": True, **({"dev_code": code} if settings.dev_return_code and settings.env == "dev" else {})}


@router.post("/verify")
def verify(body: VerifyRequest, conn=Depends(get_conn)):
    row = conn.execute(
        """select id, name, code_hash, attempts, terms_version from otp_codes
           where phone = %s and not consumed and expires_at > now()
           order by created_at desc limit 1 for update""",
        (body.phone,),
    ).fetchone()
    if row is None:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Code expiré ou inexistant")
    if row["attempts"] >= MAX_ATTEMPTS:
        raise HTTPException(status.HTTP_429_TOO_MANY_REQUESTS, "Trop d'essais. Demandez un nouveau code.")
    if not hmac.compare_digest(row["code_hash"], hash_code(body.phone, body.code)):
        conn.execute("update otp_codes set attempts = attempts + 1 where id = %s", (row["id"],))
        conn.commit()  # l'essai raté doit rester compté même si on renvoie une erreur
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Code incorrect")
    conn.execute("update otp_codes set consumed = true where id = %s", (row["id"],))
    user = conn.execute(
        """insert into users (phone, full_name) values (%s, %s)
           on conflict (phone) do update set full_name = case
             when users.full_name = '' then excluded.full_name else users.full_name end
           returning id, phone, full_name, role""",
        (body.phone, row["name"] or ""),
    ).fetchone()
    if row["terms_version"] == settings.terms_version:
        conn.execute(
            "update users set terms_accepted_at = now(), terms_version = %s where id = %s",
            (row["terms_version"], user["id"]),
        )
    audit(conn, user["id"], "login", "auth")
    return _issue_tokens(conn, user)


@router.post("/refresh")
def refresh(body: RefreshRequest, conn=Depends(get_conn)):
    row = conn.execute(
        """select t.id, u.id as uid, u.phone, u.full_name, u.role
           from refresh_tokens t join users u on u.id = t.user_id
           where t.token_hash = %s and not t.revoked and t.expires_at > now() for update of t""",
        (hash_token(body.refresh_token),),
    ).fetchone()
    if row is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Session expirée")
    conn.execute("update refresh_tokens set revoked = true where id = %s", (row["id"],))
    user = {"id": row["uid"], "phone": row["phone"], "full_name": row["full_name"], "role": row["role"]}
    return _issue_tokens(conn, user)


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
def logout(body: RefreshRequest, conn=Depends(get_conn)):
    conn.execute("update refresh_tokens set revoked = true where token_hash = %s", (hash_token(body.refresh_token),))
