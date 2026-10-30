from fastapi.testclient import TestClient

from app.main import app, items

client = TestClient(app)


def setup_function():
    items.clear()


def test_health():
    assert client.get("/api/health").json() == {"ok": True}


def test_add_and_list():
    r = client.post("/api/items", json={"name": "milk"})
    assert r.status_code == 201
    assert client.get("/api/items").json() == [{"id": 1, "name": "milk"}]


def test_empty_name_rejected():
    assert client.post("/api/items", json={"name": "  "}).status_code == 400


def test_index_served():
    r = client.get("/")
    assert r.status_code == 200 and "<html" in r.text
