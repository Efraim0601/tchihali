from datetime import date, timedelta


def next_weekday(n=3) -> date:
    d = date.today() + timedelta(days=n)
    while d.weekday() >= 5:
        d += timedelta(days=1)
    return d


def booking(day, time="10:30", dietitian="estelle", mode="video", method="orange_money"):
    return {"dietitian_id": dietitian, "day": day.isoformat(), "time": time, "mode": mode,
            "method": method, "phone": "+237677213690"}


# ---------- Authentification ----------
def test_health(client):
    assert client.get("/health").json() == {"status": "ok"}


def test_protected_routes_need_login(client):
    for path in ("/v1/me", "/v1/dietitians", "/v1/appointments/mine", "/v1/me/health"):
        assert client.get(path).status_code == 401, path


def test_login_flow_and_profile(client, login):
    headers, data = login("Nadège Ngono")
    assert data["user"]["full_name"] == "Nadège Ngono"
    assert data["user"]["role"] == "patient"
    me = client.get("/v1/me", headers=headers).json()
    assert me["full_name"] == "Nadège Ngono"


def test_wrong_code_then_lockout(client):
    phone = "+237600099001"
    client.post("/v1/auth/request-code", json={"phone": phone})
    for _ in range(5):
        assert client.post("/v1/auth/verify", json={"phone": phone, "code": "000000"}).status_code in (400,)
    # après 5 essais ratés, même un code quelconque est refusé
    assert client.post("/v1/auth/verify", json={"phone": phone, "code": "111111"}).status_code == 429


def test_code_is_single_use(client):
    phone = "+237600099002"
    code = client.post("/v1/auth/request-code", json={"phone": phone}).json()["dev_code"]
    assert client.post("/v1/auth/verify", json={"phone": phone, "code": code}).status_code == 200
    assert client.post("/v1/auth/verify", json={"phone": phone, "code": code}).status_code == 400


def test_code_rate_limit(client):
    phone = "+237600099003"
    codes = [client.post("/v1/auth/request-code", json={"phone": phone}).status_code for _ in range(4)]
    assert codes == [202, 202, 202, 429]


def test_invalid_phone_rejected(client):
    assert client.post("/v1/auth/request-code", json={"phone": "abc"}).status_code == 422


def test_refresh_rotates_and_logout_revokes(client, login):
    _, data = login()
    r = client.post("/v1/auth/refresh", json={"refresh_token": data["refresh_token"]})
    assert r.status_code == 200
    new = r.json()
    # l'ancien jeton ne marche plus (rotation)
    assert client.post("/v1/auth/refresh", json={"refresh_token": data["refresh_token"]}).status_code == 401
    assert client.post("/v1/auth/logout", json={"refresh_token": new["refresh_token"]}).status_code == 204
    assert client.post("/v1/auth/refresh", json={"refresh_token": new["refresh_token"]}).status_code == 401


def test_tampered_token_rejected(client, login):
    headers, _ = login()
    bad = {"Authorization": headers["Authorization"][:-3] + "abc"}
    assert client.get("/v1/me", headers=bad).status_code == 401


# ---------- Annuaire et créneaux ----------
def test_directory(client, login):
    headers, _ = login()
    items = client.get("/v1/dietitians", headers=headers).json()
    assert [d["id"] for d in items] == ["aissatou", "estelle", "serge"]
    estelle = next(d for d in items if d["id"] == "estelle")
    assert estelle["video"] and estelle["in_person"] and estelle["next_slot"]
    assert next(d for d in items if d["id"] == "serge")["in_person"] is False


def test_slots_empty_on_weekend_and_holiday(client, login):
    headers, _ = login()
    d = date.today() + timedelta(days=10)
    while d.weekday() != 5:  # samedi
        d += timedelta(days=1)
    assert client.get(f"/v1/dietitians/estelle/slots?day={d}", headers=headers).json() == []
    xmas = date(date.today().year + 1, 12, 25)
    assert client.get(f"/v1/dietitians/estelle/slots?day={xmas}", headers=headers).json() == []


# ---------- Réservation ----------
def test_booking_marks_slot_taken_and_blocks_double_booking(client, login):
    h1, _ = login()
    h2, _ = login()
    day = next_weekday(5)
    r = client.post("/v1/appointments", json=booking(day, "11:30"), headers=h1)
    assert r.status_code == 201, r.text
    assert r.json()["price_fcfa"] == 12000 and r.json()["status"] == "pending"
    slots = client.get(f"/v1/dietitians/estelle/slots?day={day}", headers=h2).json()
    assert {"time": "11:30", "taken": True} in slots
    assert client.post("/v1/appointments", json=booking(day, "11:30"), headers=h2).status_code == 409
    assert len(client.get("/v1/appointments/mine", headers=h1).json()) == 1
    assert client.get("/v1/appointments/mine", headers=h2).json() == []  # isolation entre patients


def test_server_sets_price_and_checks_mode(client, login):
    headers, _ = login()
    day = next_weekday(6)
    r = client.post("/v1/appointments", json=booking(day, "09:00", mode="office"), headers=headers)
    assert r.status_code == 201 and r.json()["price_fcfa"] == 15000
    # Serge ne fait pas de cabinet ; Aïssatou ne fait pas de vidéo
    assert client.post("/v1/appointments", json=booking(day, "09:00", "serge", "office"), headers=headers).status_code == 400
    assert client.post("/v1/appointments", json=booking(day, "09:00", "aissatou", "video"), headers=headers).status_code == 400


def test_booking_requires_mobile_number_and_valid_slot(client, login):
    headers, _ = login()
    day = next_weekday(7)
    no_phone = booking(day, "14:00") | {"phone": None}
    assert client.post("/v1/appointments", json=no_phone, headers=headers).status_code == 400
    assert client.post("/v1/appointments", json=booking(day, "03:00"), headers=headers).status_code == 400
    card = booking(day, "14:00", method="card") | {"phone": None}
    assert client.post("/v1/appointments", json=card, headers=headers).status_code == 201


# ---------- Profil de santé ----------
def test_health_profile_roundtrip_and_isolation(client, login):
    h1, _ = login()
    h2, _ = login()
    empty = client.get("/v1/me/health", headers=h1).json()
    assert empty["goal"] is None and empty["conditions"] == [] and empty["height_cm"] is None
    r = client.put("/v1/me/health", json={"goal": 1, "conditions": [0, 2], "allergies": [3],
                                          "height_cm": 165, "goal_weight_kg": 75}, headers=h1)
    assert r.status_code == 200
    got = client.get("/v1/me/health", headers=h1).json()
    assert got["goal"] == 1 and got["conditions"] == [0, 2] and got["allergies"] == [3]
    assert got["height_cm"] == 165 and got["goal_weight_kg"] == 75.0
    assert client.get("/v1/me/health", headers=h2).json()["goal"] is None
    assert client.put("/v1/me/health", json={"goal": 9}, headers=h1).status_code == 422


# ---------- Recettes (publiques) ----------
def test_recipes(client):
    items = client.get("/v1/recipes").json()
    assert len(items) == 6
    ndole = client.get("/v1/recipes/ndole").json()
    assert ndole["detail_kcal"] == 420 and len(ndole["ingredients"]) == 4
    assert client.get("/v1/recipes/inconnue").status_code == 404


# ---------- Messages ----------
def test_messages_private_per_patient(client, login):
    h1, _ = login()
    h2, _ = login()
    r = client.post("/v1/messages", json={"dietitian_id": "estelle", "body": "  Bonjour  "}, headers=h1)
    assert r.status_code == 201 and r.json()["body"] == "Bonjour" and r.json()["from_me"] is True
    msgs = client.get("/v1/messages?dietitian_id=estelle", headers=h1).json()
    assert [m["body"] for m in msgs] == ["Bonjour"]
    assert client.get("/v1/messages?dietitian_id=estelle", headers=h2).json() == []
    after = client.get(f"/v1/messages?dietitian_id=estelle&after_id={msgs[-1]['id']}", headers=h1).json()
    assert after == []
    assert client.post("/v1/messages", json={"dietitian_id": "estelle", "body": "   "}, headers=h1).status_code == 422
    assert client.post("/v1/messages", json={"dietitian_id": "nope", "body": "x"}, headers=h1).status_code == 404
