import json
from datetime import date, timedelta

import psycopg

from .conftest import TEST_URL


def next_weekday(n):
    d = date.today() + timedelta(days=n)
    while d.weekday() >= 5:
        d += timedelta(days=1)
    return d


def book(client, headers, day, time="09:00", dietitian="estelle"):
    r = client.post("/v1/appointments", headers=headers, json={
        "dietitian_id": dietitian, "day": day.isoformat(), "time": time, "mode": "video",
        "method": "orange_money", "phone": "+237677213690"})
    assert r.status_code == 201, r.text
    return r.json()


def test_patient_cannot_use_pro_endpoints(client, login):
    h, _ = login()
    for path in ("/v1/pro/agenda?week_start=2026-11-16", "/v1/pro/requests", "/v1/pro/patients", "/v1/pro/conversations"):
        assert client.get(path, headers=h).status_code == 403, path
    assert client.get("/v1/pro/requests").status_code == 401


def test_request_accept_and_refuse_flow(client, login, pro):
    h, data = login("Paul Atangana")
    d1, d2 = next_weekday(20), next_weekday(21)
    a1 = book(client, h, d1, "09:00")
    a2 = book(client, h, d2, "10:30")
    reqs = client.get("/v1/pro/requests", headers=pro["estelle"]).json()
    ids = {r["id"]: r for r in reqs}
    assert a1["id"] in ids and ids[a1["id"]]["initials"] == "PA"
    assert client.get("/v1/pro/requests", headers=pro["serge"]).json() == []  # Serge ne voit pas les demandes d'Estelle
    assert client.post(f"/v1/pro/appointments/{a1['id']}/decision", json={"accept": True}, headers=pro["serge"]).status_code == 404

    assert client.post(f"/v1/pro/appointments/{a1['id']}/decision", json={"accept": True}, headers=pro["estelle"]).json()["status"] == "confirmed"
    assert client.post(f"/v1/pro/appointments/{a1['id']}/decision", json={"accept": True}, headers=pro["estelle"]).status_code == 404  # déjà traitée
    assert client.post(f"/v1/pro/appointments/{a2['id']}/decision", json={"accept": False}, headers=pro["estelle"]).json()["status"] == "refused"

    mine = {a["id"]: a["status"] for a in client.get("/v1/appointments/mine", headers=h).json()}
    assert mine[a1["id"]] == "confirmed" and mine[a2["id"]] == "refused"
    kinds = [n["kind"] for n in client.get("/v1/notifications", headers=h).json()["items"]]
    assert "appointment_confirmed" in kinds and "appointment_refused" in kinds
    # le créneau refusé est de nouveau libre
    slots = client.get(f"/v1/dietitians/estelle/slots?day={d2}", headers=h).json()
    assert {"time": "10:30", "taken": False} in slots
    with psycopg.connect(TEST_URL) as c:
        assert c.execute("select status from payments where appointment_id = %s", (a2["id"],)).fetchone()[0] == "refunded"
    # la diététicienne a été notifiée de la demande
    assert any(n["kind"] == "appointment_request" for n in client.get("/v1/notifications", headers=pro["estelle"]).json()["items"])


def test_agenda_lists_confirmed_only(client, login, pro):
    h, _ = login("Grâce Ekotto")
    day = next_weekday(25)
    a = book(client, h, day, "14:00")
    week = (day - timedelta(days=day.weekday())).isoformat()
    before = client.get(f"/v1/pro/agenda?week_start={week}", headers=pro["estelle"]).json()["appointments"]
    assert a["id"] not in [x["id"] for x in before]
    client.post(f"/v1/pro/appointments/{a['id']}/decision", json={"accept": True}, headers=pro["estelle"])
    after = client.get(f"/v1/pro/agenda?week_start={week}", headers=pro["estelle"]).json()["appointments"]
    assert a["id"] in [x["id"] for x in after]


def test_patients_are_only_visible_to_linked_dietitian(client, login, pro):
    h, data = login("Ibrahim Njoya")
    book(client, h, next_weekday(30), "11:30")
    pid = data["user"]["id"]
    names = [p["name"] for p in client.get("/v1/pro/patients", headers=pro["estelle"]).json()]
    assert "Ibrahim Njoya" in names
    assert "Ibrahim Njoya" not in [p["name"] for p in client.get("/v1/pro/patients", headers=pro["serge"]).json()]
    assert client.get(f"/v1/pro/patients/{pid}", headers=pro["estelle"]).status_code == 200
    assert client.get(f"/v1/pro/patients/{pid}", headers=pro["serge"]).status_code == 404
    assert client.put(f"/v1/pro/patients/{pid}/note", json={"body": "x"}, headers=pro["serge"]).status_code == 404


def test_patient_detail_kpis_late_meal_and_private_note(client, login, pro):
    h, data = login("Nadège Ngono")
    pid = data["user"]["id"]
    book(client, h, next_weekday(35), "15:30")
    client.put("/v1/me/health", json={"goal": 1, "conditions": [0], "allergies": [1], "height_cm": 165, "birth_year": 1988}, headers=h)
    for i, w in enumerate([84.0, 82.0, 79.6]):
        client.post("/v1/measurements", json={"measured_on": (date.today() - timedelta(days=40 - 20 * i)).isoformat(), "weight_kg": w}, headers=h)
    client.post("/v1/meals", json={"meal_type": "dinner", "name": "Biscuits, soda", "kcal": 330,
                                  "eaten_at": ((date.today() - timedelta(days=1)).isoformat() + "T22:10:00+01:00")}, headers=h)
    p = client.get(f"/v1/pro/patients/{pid}", headers=pro["estelle"]).json()
    assert p["age"] == date.today().year - 1988 and p["height_cm"] == 165
    assert p["kpis"]["weight"] == {"value": 79.6, "delta": -4.4}
    assert p["kpis"]["waist"] is None and p["conditions"] == [0] and p["allergies"] == [1]
    assert p["meals"][0]["late"] is True and len(p["weight_series"]) == 3
    client.put(f"/v1/pro/patients/{pid}/note", json={"body": "Stress en fin de mois"}, headers=pro["estelle"])
    assert client.get(f"/v1/pro/patients/{pid}", headers=pro["estelle"]).json()["note"] == "Stress en fin de mois"
    # la note n'apparaît dans aucune réponse destinée au patient
    for path in ("/v1/me", "/v1/me/health", "/v1/record", "/v1/progress"):
        assert "Stress en fin de mois" not in client.get(path, headers=h).text


def test_report_draft_edit_send_and_patient_sees_it(client, login, pro):
    h, data = login("Linda Kamga")
    pid = data["user"]["id"]
    book(client, h, next_weekday(40), "17:00")
    r = client.get(f"/v1/pro/reports/{pid}", headers=pro["estelle"]).json()
    assert r["status"] == "draft" and r["session_no"] == 1 and len(r["plan"]) == 7
    # envoyer un résumé vide est refusé
    assert client.post(f"/v1/pro/reports/{pid}/send", headers=pro["estelle"]).status_code == 422
    plan = [{"meals": [{"text": f"Repas {d}-{i}", "kcal": 300 + i} for i in range(4)]} for d in range(7)]
    body = {"summary": "Belle progression", "goals": [{"text": "Foléré sans sucre", "done": True}],
            "plan": plan, "measures": {"weight_kg": 79.1, "waist_cm": 91.5, "glucose_gl": 1.05}}
    assert client.put(f"/v1/pro/reports/{pid}", json=body, headers=pro["estelle"]).status_code == 200
    assert client.get("/v1/record", headers=h).json()["session"] is None  # brouillon : invisible pour la patiente
    assert client.post(f"/v1/pro/reports/{pid}/send", headers=pro["estelle"]).json()["status"] == "sent"
    assert client.put(f"/v1/pro/reports/{pid}", json=body, headers=pro["estelle"]).status_code == 409  # plus de brouillon

    rec = client.get("/v1/record", headers=h).json()
    assert rec["session"]["summary"] == "Belle progression" and rec["session"]["session_no"] == 1
    assert len(rec["plan"]) == 4 and len(rec["documents"]) == 1 and rec["documents"][0]["downloadable"]
    pdf = client.get(f"/v1/documents/{rec['documents'][0]['id']}/download", headers=h)
    assert pdf.status_code == 200 and pdf.content.startswith(b"%PDF")
    p = client.get("/v1/progress", headers=h).json()
    assert p["weight"][-1]["value"] == 79.1 and p["waist"][-1]["value"] == 91.5
    assert p["badges"]["first_session"] is True
    assert "report_sent" in [n["kind"] for n in client.get("/v1/notifications", headers=h).json()["items"]]
    # séance suivante : numéro incrémenté, nouveau brouillon
    assert client.get(f"/v1/pro/reports/{pid}", headers=pro["estelle"]).json()["session_no"] == 2
    # un autre patient ne peut pas télécharger ce document
    h2, _ = login()
    assert client.get(f"/v1/documents/{rec['documents'][0]['id']}/download", headers=h2).status_code == 404


def test_report_validation(client, login, pro):
    h, data = login("Martin Essomba")
    pid = data["user"]["id"]
    book(client, h, next_weekday(45), "09:00")
    client.get(f"/v1/pro/reports/{pid}", headers=pro["estelle"])
    bad = {"summary": "x", "measures": {"weight_kg": 5}}
    assert client.put(f"/v1/pro/reports/{pid}", json=bad, headers=pro["estelle"]).status_code == 422
    assert client.get(f"/v1/pro/reports/{pid}", headers=pro["serge"]).status_code == 404


def test_pro_chat_roundtrip_and_notifications(client, login, pro):
    h, data = login("Hervé Tchoumi")
    pid = data["user"]["id"]
    assert client.post("/v1/messages", json={"dietitian_id": "estelle", "body": "Bonjour"}, headers=h).status_code == 201
    convs = client.get("/v1/pro/conversations", headers=pro["estelle"]).json()
    assert any(c["patient_id"] == pid and c["last"] == "Bonjour" and c["from_patient"] for c in convs)
    r = client.post("/v1/pro/messages", json={"patient_id": pid, "body": "Bonjour, comment allez-vous ?"}, headers=pro["estelle"])
    assert r.status_code == 201
    mine = client.get("/v1/messages?dietitian_id=estelle", headers=h).json()
    assert [m["from_me"] for m in mine] == [True, False]
    assert "new_message" in [n["kind"] for n in client.get("/v1/notifications", headers=h).json()["items"]]
    assert client.get(f"/v1/pro/messages?patient_id={pid}", headers=pro["serge"]).status_code == 404


def test_availability_management(client, pro, login):
    h, _ = login()
    r = client.post("/v1/pro/availability", json={"weekday": 6, "start_time": "10:00"}, headers=pro["estelle"])
    assert r.status_code == 201
    assert {"weekday": 6, "start_time": "10:00"} in client.get("/v1/pro/availability", headers=pro["estelle"]).json()
    saturday = date.today() + timedelta(days=(5 - date.today().weekday()) % 7 + 14)
    assert {"time": "10:00", "taken": False} in client.get(f"/v1/dietitians/estelle/slots?day={saturday}", headers=h).json()
    assert client.delete("/v1/pro/availability?weekday=6&start_time=10:00", headers=pro["estelle"]).status_code == 204
    assert client.get(f"/v1/dietitians/estelle/slots?day={saturday}", headers=h).json() == []
    assert client.post("/v1/pro/availability", json={"weekday": 9, "start_time": "10:00"}, headers=pro["estelle"]).status_code == 422
