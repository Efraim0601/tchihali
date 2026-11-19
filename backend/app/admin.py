"""Administration : `python -m app.admin dietitian +237677000000 estelle`
Donne le rôle diététicien à un numéro de téléphone et le lie à une fiche de l'annuaire.
Le diététicien se connecte ensuite avec un code SMS, comme un patient."""

import sys

import psycopg

from .config import settings


def link_dietitian(phone: str, dietitian_id: str, name: str | None = None) -> None:
    with psycopg.connect(settings.database_url) as conn:
        d = conn.execute("select id, name, user_id from dietitians where id = %s", (dietitian_id,)).fetchone()
        if d is None:
            raise SystemExit(f"Fiche diététicien inconnue : {dietitian_id}")
        if d[2] is not None:
            raise SystemExit("Cette fiche est déjà liée à un compte")
        row = conn.execute(
            """insert into users (phone, full_name, role) values (%s, %s, 'dietitian')
               on conflict (phone) do update set role = 'dietitian' returning id""",
            (phone, name or d[1]),
        ).fetchone()
        conn.execute("update dietitians set user_id = %s where id = %s", (row[0], dietitian_id))
        print(f"{phone} est maintenant lié à {d[1]} ({dietitian_id})")


if __name__ == "__main__":
    if len(sys.argv) < 4 or sys.argv[1] != "dietitian":
        raise SystemExit("usage : python -m app.admin dietitian +237XXXXXXXXX <id-fiche>")
    link_dietitian(sys.argv[2], sys.argv[3])
