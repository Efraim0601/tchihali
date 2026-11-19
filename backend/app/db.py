from collections.abc import Iterator

from psycopg.rows import dict_row
from psycopg_pool import ConnectionPool

from .config import settings

pool: ConnectionPool | None = None


def init_pool() -> None:
    global pool
    pool = ConnectionPool(
        settings.database_url,
        min_size=1,
        max_size=10,
        kwargs={"row_factory": dict_row},
        open=True,
    )


def close_pool() -> None:
    global pool
    if pool is not None:
        pool.close()
        pool = None


def get_conn() -> Iterator:
    """Une connexion par requête ; validée à la fin, annulée en cas d'erreur."""
    assert pool is not None, "pool non initialisé"
    with pool.connection() as conn:
        yield conn


def audit(conn, user_id, action: str, resource: str) -> None:
    conn.execute(
        "insert into audit_log (user_id, action, resource) values (%s, %s, %s)",
        (user_id, action, resource),
    )
