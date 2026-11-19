def notify(conn, user_id, kind: str, data: dict | None = None, title: str = "", body: str = "") -> None:
    """Notification dans l'application. `kind` + `data` sont traduits côté application
    (rendez-vous confirmé / refusé, nouveau message, compte rendu envoyé…)."""
    import json

    conn.execute(
        "insert into notifications (user_id, kind, title, body, data) values (%s, %s, %s, %s, %s)",
        (user_id, kind, title, body, json.dumps(data or {})),
    )
