import pytest
import random
import string
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from database import Base
from main import app, get_db

SQLALCHEMY_DATABASE_URL = "sqlite+pysqlite:///:memory:", 

sqlite_shared_name = "test_db_{}".format(
            random.sample(string.ascii_letters, k=4)
        )

engine = create_engine("sqlite:///file:{}?mode=memory&cache=shared&uri=true".format(
        sqlite_shared_name), echo=True, future=True)

Base.metadata.create_all(bind=engine)

TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db

client = TestClient(app)

@pytest.fixture
def test_data():
    # Test data setup
    activity_data = {"name": "Activity 1", "original_estimate": 10.0}
    task_data = {"activity_id": 1, "name": "Task 1", "start_time": "2023-01-01T10:00:00", "end_time": "2023-01-01T12:00:00"}
    time_entry_data = {"task_id": 1, "start_time": "2023-01-01T10:00:00", "end_time": "2023-01-01T11:00:00"}
    yield activity_data, task_data, time_entry_data
    # Teardown

# Activities
def test_create_activity(test_data):
    activity_data, _, _ = test_data
    response = client.post("/api/activities/", json=activity_data)
    assert response.status_code == 201
    assert response.json()["name"] == activity_data["name"]
    assert response.json()["original_estimate"] == activity_data["original_estimate"]

def test_get_activity(test_data):
    activity_data, _, _ = test_data
    response = client.post("/api/activities/", json=activity_data)
    activity_id = response.json()["activity_id"]
    response = client.get(f"/api/activities/{activity_id}/")
    assert response.status_code == 200
    assert response.json()["name"] == activity_data["name"]
    assert response.json()["original_estimate"] == activity_data["original_estimate"]

def test_update_activity(test_data):
    activity_data, _, _ = test_data
    response = client.post("/api/activities/", json=activity_data)
    activity_id = response.json()["activity_id"]
    update_data = {"name": "Updated Activity", "original_estimate": 20.0, "remaining_hours": 10.0, "completed_hours": 5.0}
    response = client.put(f"/api/activities/{activity_id}/", json=update_data)
    assert response.status_code == 200
    assert response.json()["name"] == update_data["name"]
    assert response.json()["original_estimate"] == update_data["original_estimate"]
    assert response.json()["remaining_hours"] == update_data["remaining_hours"]
    assert response.json()["completed_hours"] == update_data["completed_hours"]

def test_delete_activity(test_data):
    activity_data, _, _ = test_data
    response = client.post("/api/activities/", json=activity_data)
    activity_id = response.json()["activity_id"]
    response = client.delete(f"/api/activities/{activity_id}/")
    assert response.status_code == 200
    response = client.delete(f"/api/activities/{activity_id}/")
    assert response.status_code == 404

def test_list_activities(test_data):
    activity_data, _, _ = test_data
    response = client.post("/api/activities/", json=activity_data)
    response = client.get("/api/activities/")
    assert response.status_code == 200
    assert len(response.json()) > 0

# Tasks
def test_create_task(test_data):
    _, task_data, _ = test_data
    response = client.post("/api/tasks/", json=task_data)
    assert response.status_code == 201
    assert response.json()["name"] == task_data["name"]
    assert response.json()["start_time"] is None
    assert response.json()["end_time"] is None

def test_get_task(test_data):
    _, task_data, _ = test_data
    response = client.post("/api/tasks/", json=task_data)
    task_id = response.json()["task_id"]
    response = client.get(f"/api/tasks/{task_id}/")
    assert response.status_code == 200
    assert response.json()["name"] == task_data["name"]
    assert response.json()["start_time"] is None
    assert response.json()["end_time"] is None

def test_update_task(test_data):
    _, task_data, _ = test_data
    response = client.post("/api/tasks/", json=task_data)
    task_id = response.json()["task_id"]
    update_data = {"name": "Updated Task", "start_time": "2023-01-01T12:00:00", "end_time": "2023-01-01T14:00:00", "duration": 2.0}
    response = client.put(f"/api/tasks/{task_id}/", json=update_data)
    assert response.status_code == 200
    assert response.json()["name"] == update_data["name"]
    assert response.json()["start_time"] == update_data["start_time"]
    assert response.json()["end_time"] == update_data["end_time"]
    assert response.json()["duration"] == update_data["duration"]

def test_delete_task(test_data):
    _, task_data, _ = test_data
    response = client.post("/api/tasks/", json=task_data)
    task_id = response.json()["task_id"]
    response = client.delete(f"/api/tasks/{task_id}/")
    assert response.status_code == 200

def test_list_tasks(test_data):
    _, task_data, _ = test_data
    response = client.post("/api/tasks/", json=task_data)
    response = client.get(f"/api/tasks/activity/{task_data['activity_id']}/")
    assert response.status_code == 200
    assert len(response.json()) > 1

## Time Entries
def test_create_time_entry(test_data):
    _, task_data, _ = test_data
    response = client.post("/api/tasks/", json=task_data)
    task_id = response.json()["task_id"]

    response = client.post(f"/api/time_entries/{task_id}/start")
    assert response.status_code == 200
    time_entry_id = response.json()["time_entry_id"]

    response = client.get(f"/api/time_entries/{time_entry_id}/")
    assert response.status_code == 200
    assert response.json()["start_time"] is not None
    assert response.json()["end_time"] is None

def test_stop_time_entry(test_data):
    _, task_data, _ = test_data
    response = client.post("/api/tasks/", json=task_data)
    task_id = response.json()["task_id"]

    response = client.post(f"/api/time_entries/{task_id}/start")
    assert response.status_code == 200
    time_entry_id = response.json()["time_entry_id"]

    response = client.put(f"/api/time_entries/{time_entry_id}/stop")
    assert response.status_code == 200

    response = client.get(f"/api/time_entries/{time_entry_id}/")
    assert response.status_code == 200
    assert response.json()["end_time"] is not None

def test_get_time_entry(test_data):
    _, task_data, _ = test_data
    response = client.post("/api/tasks/", json=task_data)
    task_id = response.json()["task_id"]

    response = client.post(f"/api/time_entries/{task_id}/start")
    assert response.status_code == 200
    time_entry_id = response.json()["time_entry_id"]

    response = client.get(f"/api/time_entries/{time_entry_id}/")
    assert response.status_code == 200
    assert response.json()["task_id"] == task_id

def test_list_time_entries(test_data):
    _, task_data, _ = test_data
    response = client.post("/api/tasks/", json=task_data)
    task_id = response.json()["task_id"]

    response = client.post(f"/api/time_entries/{task_id}/start")
    assert response.status_code == 200

    response = client.get(f"/api/time_entries/task/{task_id}/")
    assert response.status_code == 200
    assert len(response.json()) == 1
    assert response.json()[0]["task_id"] == task_id


# Run all tests
if __name__ == '__main__':
    pytest.main()

