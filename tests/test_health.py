from fastapi.testclient import TestClient

from nestegg import app

client = TestClient(app)


def test_health_endpoint_returns_200():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"ok": True}
