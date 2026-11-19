import os

import psycopg
import pytest

ADMIN_URL = "postgresql://tchihali:tchihali@127.0.0.1:55432/postgres"
TEST_URL = "postgresql://tchihali:tchihali@127.0.0.1:55432/tchihali_test"

# Doit être défini avant l'import de l'application.
os.environ["TCHIHALI_ENV"] = "dev"
os.environ["TCHIHALI_DATABASE_URL"] = TEST_URL
os.environ["TCHIHALI_DEV_RETURN_CODE"] = "true"


@pytest.fixture(scope="session")
def client():
    with psycopg.connect(ADMIN_URL, autocommit=True) as c:
        c.execute("drop database if exists tchihali_test with (force)")
        c.execute("create database tchihali_test")
    from app import migrate

    migrate.run(TEST_URL, seed=True)
    from fastapi.testclient import TestClient

    from app.main import app

    with TestClient(app) as tc:
        yield tc


_counter = {"n": 0}


@pytest.fixture
def login(client):
    """Crée un patient neuf et renvoie (en-têtes, utilisateur)."""

    def _login(name="Patiente Test"):
        _counter["n"] += 1
        phone = f"+2376000{_counter['n']:05d}"
        r = client.post("/v1/auth/request-code", json={"phone": phone, "name": name})
        assert r.status_code == 202, r.text
        r = client.post("/v1/auth/verify", json={"phone": phone, "code": r.json()["dev_code"]})
        assert r.status_code == 200, r.text
        data = r.json()
        return {"Authorization": f"Bearer {data['access_token']}"}, data

    return _login


def _login_phone(client, phone, name=""):
    code = client.post("/v1/auth/request-code", json={"phone": phone, "name": name}).json()["dev_code"]
    data = client.post("/v1/auth/verify", json={"phone": phone, "code": code}).json()
    return {"Authorization": f"Bearer {data['access_token']}"}, data


@pytest.fixture(scope="session")
def pro(client):
    """Estelle (diététicienne liée à la fiche « estelle ») et Serge (autre diététicien)."""
    from app import admin

    out = {}
    for did, phone in (("estelle", "+237699000001"), ("serge", "+237699000002")):
        admin.link_dietitian(phone, did)
        out[did] = _login_phone(client, phone)[0]
    return out
