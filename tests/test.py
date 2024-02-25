from fastapi.testclient import TestClient

from api.main import app

client = TestClient(app)

def test():
	assert (1, 2, 3) == (1, 2, 3)
	assert "Hello" == "Hello"


def test_api():
	response = client.post("/predict", json={"price": 10, "temperature": 2})
	assert response.status_code == 200
	assert 10 == 20