import io
import json
from datetime import date, timedelta

import psycopg

from .conftest import TEST_URL

JPEG = b"\xff\xd8\xff\xe0" + b"\x00" * 64


def test_new_account_requires_current_terms(client):
    phone = "+237600088001"
    assert client.post("/v1/auth/request-code", json={"phone": phone}).status_code == 422
    assert client.post("/v1/auth/request-code", json={"phone": phone, "terms_version": "1999-01"}).status_code == 422
    r = client.post("/v1/auth/request-code", json={"phone": phone, "terms_version": "2026-11"})
    assert r.status_code == 202
    client.post("/v1/auth/verify", json={"phone": phone, "code": r.json()["dev_code"]})
    with psycopg.connect(TEST_URL) as c:
        row = c.execute("select terms_version, terms_accepted_at from users where phone = %s", (phone,)).fetchone()
    assert row[0] == "2026-11" and row[1] is not None  # preuve datée du consentement


def test_existing_user_can_log_in_without_resending_terms(client, login):
    _, data = login()
    r = client.post("/v1/auth/request-code", json={"phone": data["user"]["phone"]})
    assert r.status_code == 202


def test_export_contains_own_data_only(client, login):
    h1, d1 = login("Exportée Un")
    h2, _ = login("Autre Patient")
    client.put("/v1/me/health", json={"goal": 2, "conditions": [1]}, headers=h1)
    client.post("/v1/meals", json={"meal_type": "lunch", "name": "Koki de haricots", "kcal": 390}, headers=h1)
    client.post("/v1/meals", json={"meal_type": "lunch", "name": "Repas de l'autre", "kcal": 100}, headers=h2)
    client.post("/v1/messages", json={"dietitian_id": "estelle", "body": "Bonjour docteur"}, headers=h1)
    r = client.get("/v1/me/export", headers=h1)
    assert r.status_code == 200 and "tchihali-donnees.json" in r.headers["content-disposition"]
    assert r.headers["cache-control"] == "no-store"
    data = r.json()
    assert data["profile"][0]["full_name"] == "Exportée Un"
    assert [m["name"] for m in data["meals"]] == ["Koki de haricots"]
    assert data["messages"][0]["body"] == "Bonjour docteur" and data["health"][0]["goal"] == 2
    assert "Repas de l'autre" not in json.dumps(data) and "Autre Patient" not in json.dumps(data)
    assert client.get("/v1/me/export").status_code == 401


def test_delete_account_removes_everything(client, login, pro):
    h, data = login("À Supprimer")
    uid = data["user"]["id"]
    fid = client.post("/v1/files", data={"kind": "meal_photo"}, files={"file": ("a.jpg", io.BytesIO(JPEG), "image/jpeg")}, headers=h).json()["id"]
    client.post("/v1/meals", json={"meal_type": "lunch", "name": "Plat", "kcal": 300, "photo_file_id": fid}, headers=h)
    client.post("/v1/measurements", json={"measured_on": date.today().isoformat(), "weight_kg": 80}, headers=h)
    client.post("/v1/messages", json={"dietitian_id": "estelle", "body": "Bonjour"}, headers=h)
    d = date.today() + timedelta(days=50)
    while d.weekday() >= 5:
        d += timedelta(days=1)
    booking = {"dietitian_id": "estelle", "day": d.isoformat(), "time": "17:00", "mode": "video", "method": "card"}
    assert client.post("/v1/appointments", headers=h, json=booking).status_code == 201
    assert client.delete("/v1/me", headers=h).status_code == 400  # confirmation obligatoire
    assert client.delete("/v1/me?confirm=yes", headers=h).status_code == 204
    with psycopg.connect(TEST_URL) as c:
        for table, col in [("users", "id"), ("meals", "patient_id"), ("messages", "patient_id"),
                           ("appointments", "patient_id"), ("measurements", "patient_id"), ("files", "owner_id")]:
            assert c.execute(f"select count(*) from {table} where {col} = %s", (uid,)).fetchone()[0] == 0, table
        assert c.execute("select count(*) from audit_log where action = 'delete_account'").fetchone()[0] >= 1
    assert client.get("/v1/me", headers=h).status_code == 401  # le compte n'existe plus
    h2, _ = login()  # le créneau libéré peut être réservé par quelqu'un d'autre
    assert client.post("/v1/appointments", headers=h2, json=booking).status_code == 201


def test_dietitian_cannot_delete_via_self_service(client, pro):
    assert client.delete("/v1/me?confirm=yes", headers=pro["estelle"]).status_code == 403


def test_security_headers_and_no_cache(client, login):
    h, _ = login()
    r = client.get("/v1/me", headers=h)
    assert r.headers["x-content-type-options"] == "nosniff"
    assert r.headers["cache-control"] == "no-store" and r.headers["x-frame-options"] == "DENY"
    big = client.post("/v1/files", data={"kind": "meal_photo"}, headers={**h, "content-length": str(50 * 1024 * 1024)},
                      files={"file": ("a.jpg", io.BytesIO(JPEG), "image/jpeg")})
    assert big.status_code in (413, 422)
