import io
from datetime import date, datetime, timedelta, timezone

import psycopg

from .conftest import TEST_URL

JPEG = b"\xff\xd8\xff\xe0" + b"\x00" * 64
PNG = b"\x89PNG\r\n\x1a\n" + b"\x00" * 64


def meal(**kw):
    base = {"meal_type": "lunch", "name": "Poisson braisé, miondo", "kcal": 540, "protein": 32, "carbs": 68, "fat": 14}
    return base | kw


# ---------- Journal ----------
def test_meal_crud_and_daily_totals(client, login):
    h, _ = login()
    r = client.post("/v1/meals", json=meal(), headers=h)
    assert r.status_code == 201, r.text
    mid = r.json()["id"]
    client.post("/v1/meals", json=meal(name="Bouillie de mil", kcal=280, meal_type="breakfast"), headers=h)
    today = date.today().isoformat()
    day = client.get(f"/v1/meals?day={today}", headers=h).json()
    assert day["total_kcal"] == 820 and day["target_kcal"] == 1700 and len(day["meals"]) == 2
    r = client.patch(f"/v1/meals/{mid}", json={"mood": 3, "symptoms": [0, 1]}, headers=h)
    assert r.status_code == 200 and r.json()["mood"] == 3 and r.json()["symptoms"] == [0, 1]
    assert client.patch(f"/v1/meals/{mid}", json={"mood": 9}, headers=h).status_code == 422
    assert client.delete(f"/v1/meals/{mid}", headers=h).status_code == 204
    assert client.delete(f"/v1/meals/{mid}", headers=h).status_code == 404


def test_meals_are_private_and_validated(client, login):
    h1, _ = login()
    h2, _ = login()
    mid = client.post("/v1/meals", json=meal(), headers=h1).json()["id"]
    today = date.today().isoformat()
    assert client.get(f"/v1/meals?day={today}", headers=h2).json()["meals"] == []
    assert client.patch(f"/v1/meals/{mid}", json={"mood": 1}, headers=h2).status_code == 404
    assert client.delete(f"/v1/meals/{mid}", headers=h2).status_code == 404
    assert client.post("/v1/meals", json=meal(kcal=-5), headers=h1).status_code == 422
    assert client.post("/v1/meals", json=meal(name="  "), headers=h1).status_code == 422
    future = (datetime.now(timezone.utc) + timedelta(days=2)).isoformat()
    assert client.post("/v1/meals", json=meal(eaten_at=future), headers=h1).status_code == 400


def test_daily_goals(client, login):
    h, _ = login()
    today = date.today().isoformat()
    assert client.get(f"/v1/goals?day={today}", headers=h).json()["done"] == []
    assert client.put("/v1/goals", json={"day": today, "done": [2, 1, 1]}, headers=h).json()["done"] == [1, 2]
    assert client.get(f"/v1/goals?day={today}", headers=h).json()["done"] == [1, 2]
    assert client.put("/v1/goals", json={"day": today, "done": [5]}, headers=h).status_code == 422


# ---------- Mesures et progrès ----------
def test_progress_series_bmi_and_badges(client, login):
    h, _ = login()
    client.put("/v1/me/health", json={"goal": 0, "height_cm": 165, "goal_weight_kg": 75}, headers=h)
    start = date.today() - timedelta(days=70)
    for i, w in enumerate([84.0, 82.5, 81.0, 79.6]):
        d = (start + timedelta(days=i * 21)).isoformat()
        assert client.post("/v1/measurements", json={"measured_on": d, "weight_kg": w, "waist_cm": 98 - i}, headers=h).status_code == 201
    p = client.get("/v1/progress", headers=h).json()
    assert [x["value"] for x in p["weight"]] == [84.0, 82.5, 81.0, 79.6]
    assert p["bmi"][0]["value"] == round(84.0 / 1.65**2, 1)
    assert p["goal_weight_kg"] == 75.0 and len(p["waist"]) == 4
    assert p["badges"]["lost_4kg"] is True and p["badges"]["first_session"] is False


def test_measurement_validation_and_upsert(client, login):
    h, _ = login()
    d = date.today().isoformat()
    assert client.post("/v1/measurements", json={"measured_on": d}, headers=h).status_code == 422
    assert client.post("/v1/measurements", json={"measured_on": d, "weight_kg": 5}, headers=h).status_code == 422
    client.post("/v1/measurements", json={"measured_on": d, "weight_kg": 80.0}, headers=h)
    client.post("/v1/measurements", json={"measured_on": d, "waist_cm": 90.0}, headers=h)  # même jour : fusionne
    p = client.get("/v1/progress", headers=h).json()
    assert len(p["weight"]) == 1 and len(p["waist"]) == 1


def test_journal_streak_badge(client, login):
    h, _ = login()
    for i in range(14):
        when = (datetime.now(timezone.utc) - timedelta(days=i)).isoformat()
        client.post("/v1/meals", json=meal(eaten_at=when), headers=h)
    badges = client.get("/v1/progress", headers=h).json()["badges"]
    assert badges["journal_streak_14"] is True and badges["streak_days"] >= 14


# ---------- Fichiers ----------
def test_upload_validates_type_and_size(client, login):
    h, _ = login()
    ok = client.post("/v1/files", data={"kind": "meal_photo"}, files={"file": ("a.jpg", io.BytesIO(JPEG), "image/jpeg")}, headers=h)
    assert ok.status_code == 201 and ok.json()["content_type"] == "image/jpeg"
    # un exécutable déguisé en photo est refusé : on lit le contenu, pas le nom
    bad = client.post("/v1/files", data={"kind": "meal_photo"}, files={"file": ("a.jpg", io.BytesIO(b"MZ\x90" + b"\x00" * 50), "image/jpeg")}, headers=h)
    assert bad.status_code == 415
    big = client.post("/v1/files", data={"kind": "meal_photo"}, files={"file": ("a.png", io.BytesIO(PNG + b"\x00" * (6 * 1024 * 1024)), "image/png")}, headers=h)
    assert big.status_code == 413
    assert client.post("/v1/files", data={"kind": "document"}, files={"file": ("a.jpg", io.BytesIO(JPEG), "image/jpeg")}, headers=h).status_code == 422


def test_files_only_for_owner_and_attach_to_meal_and_message(client, login):
    h1, _ = login()
    h2, _ = login()
    fid = client.post("/v1/files", data={"kind": "meal_photo"}, files={"file": ("a.jpg", io.BytesIO(JPEG), "image/jpeg")}, headers=h1).json()["id"]
    assert client.get(f"/v1/files/{fid}", headers=h1).status_code == 200
    assert client.get(f"/v1/files/{fid}", headers=h2).status_code == 404  # un autre patient ne le voit pas
    assert client.get(f"/v1/files/{fid}").status_code == 401
    assert client.post("/v1/meals", json=meal(photo_file_id=fid), headers=h2).status_code == 400  # pas sa photo
    assert client.post("/v1/meals", json=meal(photo_file_id=fid), headers=h1).status_code == 201
    # photo de message : doit être de type chat_photo
    assert client.post("/v1/messages", json={"dietitian_id": "estelle", "body": "", "photo_file_id": fid}, headers=h1).status_code == 400
    cid = client.post("/v1/files", data={"kind": "chat_photo"}, files={"file": ("a.png", io.BytesIO(PNG), "image/png")}, headers=h1).json()["id"]
    r = client.post("/v1/messages", json={"dietitian_id": "estelle", "body": "", "photo_file_id": cid}, headers=h1)
    assert r.status_code == 201 and r.json()["photo_file_id"] == cid
    assert client.post("/v1/messages", json={"dietitian_id": "estelle", "body": ""}, headers=h1).status_code == 422


# ---------- Notifications et carnet ----------
def test_notifications_list_and_read_all(client, login):
    h, data = login()
    assert client.get("/v1/notifications", headers=h).json() == {"unread": 0, "items": []}
    with psycopg.connect(TEST_URL, autocommit=True) as c:
        c.execute("insert into notifications (user_id, kind, title) values (%s, 'appointment', 'Rendez-vous confirmé')", (data["user"]["id"],))
    n = client.get("/v1/notifications", headers=h).json()
    assert n["unread"] == 1 and n["items"][0]["title"] == "Rendez-vous confirmé"
    assert client.post("/v1/notifications/read-all", headers=h).status_code == 204
    assert client.get("/v1/notifications", headers=h).json()["unread"] == 0


def test_record_shows_only_sent_reports(client, login):
    h, data = login()
    uid = data["user"]["id"]
    assert client.get("/v1/record", headers=h).json() == {"session": None, "plan": None, "documents": []}
    with psycopg.connect(TEST_URL, autocommit=True) as c:
        c.execute("insert into reports (patient_id, dietitian_id, session_no, held_on, summary, status) values (%s, 'estelle', 3, '2026-11-10', 'brouillon', 'draft')", (uid,))
    assert client.get("/v1/record", headers=h).json()["session"] is None  # un brouillon reste invisible
    plan = [{"meals": [{"text": f"Repas {d}-{i}", "kcal": 300} for i in range(4)]} for d in range(7)]
    import json
    with psycopg.connect(TEST_URL, autocommit=True) as c:
        c.execute("insert into reports (patient_id, dietitian_id, session_no, held_on, summary, goals, plan, status, sent_at) values (%s, 'estelle', 4, '2026-11-17', 'Belle progression', %s, %s, 'sent', now())",
                  (uid, json.dumps([{"text": "Foléré sans sucre", "done": False}]), json.dumps(plan)))
    rec = client.get("/v1/record", headers=h).json()
    assert rec["session"]["session_no"] == 4 and rec["session"]["summary"] == "Belle progression"
    assert len(rec["plan"]) == 4
    assert client.get("/v1/progress", headers=h).json()["badges"]["first_session"] is True
