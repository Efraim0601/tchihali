"""Applique les migrations SQL (dossier migrations/) dans l'ordre. `--seed` charge aussi seeds/seed.sql."""

import sys
from pathlib import Path

import psycopg

from .config import settings

ROOT = Path(__file__).resolve().parent.parent


def run(database_url: str | None = None, seed: bool = False) -> None:
    url = database_url or settings.database_url
    with psycopg.connect(url, autocommit=True) as conn:
        conn.execute(
            "create table if not exists schema_migrations (name text primary key, applied_at timestamptz default now())"
        )
        done = {r[0] for r in conn.execute("select name from schema_migrations")}
        for f in sorted((ROOT / "migrations").glob("*.sql")):
            if f.name in done:
                continue
            with conn.transaction():
                conn.execute(f.read_text())
                conn.execute("insert into schema_migrations (name) values (%s)", (f.name,))
            print(f"migration appliquée : {f.name}")
        if seed:
            conn.execute((ROOT / "seeds" / "seed.sql").read_text())
            print("données de démonstration chargées")


if __name__ == "__main__":
    run(seed="--seed" in sys.argv)
