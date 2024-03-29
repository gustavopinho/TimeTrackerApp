from typing import Annotated, List
from fastapi import Depends, FastAPI, HTTPException
from fastapi.openapi.docs import get_swagger_ui_html
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint
from sqlalchemy.orm import Session
from starlette.requests import Request
import uvicorn

from database import Activity, Task, TimeEntry, SessionLocal
from models import *


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# FastAPI setup
app = FastAPI()

origins = [
    "http://localhost:3000",
    "http://localhost:8000",
    "http://localhost:5001",
    "http://127.0.0.1:5001"
    "*"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class UTF8ResponseMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        response = await call_next(request)
        if "Content-Type" in response.headers:
            if "application/json" in response.headers["Content-Type"]:
                response.headers["Content-Type"] = "application/json; charset=utf-8"
        return response


app.add_middleware(UTF8ResponseMiddleware)


def convert_minutes_to_hours_and_minutes(total_minutes):
    hours = total_minutes // 60
    remaining_minutes = total_minutes % 60
    hours_with_minutes = hours + (remaining_minutes / 60)
    return hours_with_minutes


async def update_task_duration(task_id):

    db = next(get_db())

    task = db.query(Task).get(task_id)

    seconds = 0
    for time_entry in task.time_entries:
        seconds = seconds + time_entry.duration

    task.duration = seconds // 60

    db.commit()
    db.refresh(task)
    db.close()

    await update_activity_completed_hours(task.activity_id)


async def update_activity_completed_hours(activity_id):

    db = next(get_db())

    activity = db.query(Activity).get(activity_id)

    minutes = 0
    for task in activity.tasks:
        print("Task {}: {}".format(task.task_id, task.duration))
        minutes = minutes + task.duration

    activity.completed_hours = convert_minutes_to_hours_and_minutes(minutes)
    activity.remaining_hours = activity.original_estimate - activity.completed_hours

    print("Complete hours: {} Remain hours: {}".format(
        activity.completed_hours, activity.remaining_hours))

    db.commit()
    db.refresh(activity)
    db.close()

# API routes


@app.post("/api/activities/", status_code=201)
def create_activity(activity: ActivityCreate, db: Session = Depends(get_db)):
    """
    Create a new activity.
    """
    new_activity = Activity(
        name=activity.name,
        original_estimate=activity.original_estimate,
        remaining_hours=activity.original_estimate,
        completed_hours=0.0,
        finalized=False
    )
    db.add(new_activity)
    db.commit()
    db.refresh(new_activity)
    db.close()
    return new_activity.to_response_model()


@app.get("/api/activities/{activity_id}/", response_model=ActivityResponse)
def get_activity(activity_id: int, db: Session = Depends(get_db)):
    """
    Get a specific activity by ID.
    """
    activity = db.query(Activity).get(activity_id)
    db.close()
    if not activity:
        raise HTTPException(status_code=404, detail="Activity not found")
    return activity.to_response_model()


@app.put("/api/activities/{activity_id}/", response_model=ActivityResponse)
def update_activity(activity_id: int, activity: ActivityUpdate, db: Session = Depends(get_db)):
    """
    Update an existing activity.
    """
    db_activity = db.query(Activity).get(activity_id)
    if not db_activity:
        raise HTTPException(status_code=404, detail="Activity not found")

    db_activity.name = activity.name
    db_activity.original_estimate = activity.original_estimate
    db_activity.completed_hours = activity.completed_hours
    db_activity.finalized = activity.finalized
    db_activity.price_per_hour = activity.price_per_hour
    db_activity.money_received = activity.money_received

    db.commit()
    db.refresh(db_activity)
    db.close()
    return db_activity.to_response_model()


@app.delete("/api/activities/{activity_id}/", status_code=200)
def delete_activity(activity_id: int, db: Session = Depends(get_db)):
    """
    Delete an activity.
    """
    activity = db.query(Activity).get(activity_id)
    if not activity:
        raise HTTPException(status_code=404, detail="Activity not found")
    db.delete(activity)
    db.commit()
    db.close()


@app.get("/api/activities/", response_model=List[ActivityResponse])
def list_activities(finalized: bool = False, name: str = "", db: Session = Depends(get_db)):
    """
    List all activities.
    """
    activities = db.query(Activity).filter(
        Activity.finalized == finalized, Activity.name.contains(name)).all()
    db.close()
    return [activity.to_response_model() for activity in activities]


@app.post("/api/tasks/", response_model=TaskResponse, status_code=201)
def create_task(task: TaskCreate, db: Session = Depends(get_db)):
    """
    Create a new task.
    """
    activity = db.query(Activity).get(task.activity_id)
    if not activity:
        raise HTTPException(status_code=404, detail="Activity not found")

    if activity.finalized == True:
        raise HTTPException(
            status_code=400, detail="You can't create a task with finalized activity")

    new_task = Task(
        activity_id=task.activity_id,
        name=task.name,
        duration=0.0
    )
    db.add(new_task)
    db.commit()
    db.refresh(new_task)
    db.close()
    return new_task.to_response_model()


@app.get("/api/tasks/{task_id}/", response_model=TaskResponse)
def get_task(task_id: int, db: Session = Depends(get_db)):
    """
    Get a specific task by ID.
    """
    task = db.query(Task).get(task_id)
    db.close()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task.to_response_model()


@app.put("/api/tasks/{task_id}/", response_model=TaskResponse)
def update_task(task_id: int, task: TaskUpdate, db: Session = Depends(get_db)):
    """
    Update an existing task.
    """
    db_task = db.query(Task).get(task_id)
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")
    db_task.name = task.name
    db.commit()
    db.refresh(db_task)
    db.close()
    return db_task.to_response_model()


@app.put("/api/tasks/close/{task_id}/", response_model=TaskResponse)
def close_task(task_id: int, db: Session = Depends(get_db)):
    """
    Update an existing task.
    """
    db_task = db.query(Task).get(task_id)
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")

    db_task.end_time = datetime.now()
    db_task.closed = True

    db.commit()
    db.refresh(db_task)
    db.close()

    return db_task.to_response_model()


@app.delete("/api/tasks/{task_id}/", status_code=200)
async def delete_task(task_id: int, db: Session = Depends(get_db)):
    """
    Delete a task.
    """
    task = db.query(Task).get(task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")

    if task.activity.finalized == True:
        raise HTTPException(
            status_code=400, detail="You can't delete a task with finalized activity")

    db.delete(task)
    db.commit()
    db.close()

    await update_activity_completed_hours(task.activity_id)


@app.get("/api/tasks/activity/{activity_id}/", response_model=List[TaskResponse])
async def list_tasks(activity_id: int, db: Session = Depends(get_db)):
    """
    List tasks of a specific activity.
    """
    # ... implementation ...
    tasks = db.query(Task).filter(Task.activity_id == activity_id).all()
    db.close()
    return [task.to_response_model() for task in tasks]


@app.post("/api/time_entries/{task_id}/start", response_model=TimeEntryResponse)
def create_time_entry(task_id: int, db: Session = Depends(get_db)):
    """
    Create a new time entry.
    """
    task = db.query(Task).get(task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")

    if task.closed == True:
        raise HTTPException(status_code=400, detail="Task closed")

    if task.activity.finalized == True:
        raise HTTPException(
            status_code=400, detail="You can't start a task with finalized activity")

    start_time = datetime.now()
    end_time = None
    duration = None

    new_time_entry = TimeEntry(
        task_id=task.task_id,
        start_time=start_time,
        end_time=end_time,
        duration=duration
    )
    db.add(new_time_entry)

    if task.start_time is None:
        task.start_time = start_time

    db.commit()
    db.refresh(new_time_entry)
    db.refresh(task)
    db.close()
    return new_time_entry.to_response_model()

# Add a new endpoint to stop a time entry


@app.put("/api/time_entries/{time_entry_id}/stop", response_model=TimeEntryResponse)
async def stop_time_entry(time_entry_id: int, db: Session = Depends(get_db)):
    """
    Stop a time entry by ID.
    """
    time_entry = db.query(TimeEntry).get(time_entry_id)
    if not time_entry:
        raise HTTPException(status_code=404, detail="Time Entry not found")

    time_entry.end_time = datetime.now()

    duration = time_entry.end_time - time_entry.start_time
    time_entry.duration = duration.total_seconds()

    db.commit()
    db.refresh(time_entry)
    db.close()

    await update_task_duration(time_entry.task_id)

    return time_entry.to_response_model()


@app.get("/api/time_entries/{time_entry_id}/", response_model=TimeEntryResponse)
def get_time_entry(time_entry_id: int, db: Session = Depends(get_db)):
    """
    Get a specific time entry by ID.
    """
    time_entry = db.query(TimeEntry).get(time_entry_id)
    db.close()
    if not time_entry:
        raise HTTPException(status_code=404, detail="Time Entry not found")
    return time_entry.to_response_model()


@app.get("/api/time_entries/task/{task_id}/", response_model=List[TimeEntryResponse])
async def list_time_entries(task_id: int, db: Session = Depends(get_db)):
    """
    List time entries of a specific task.
    """
    # ... implementation ...
    time_entries = db.query(TimeEntry).filter(
        TimeEntry.task_id == task_id).all()
    db.close()
    return [time_entry.to_response_model() for time_entry in time_entries]


@app.get("/api/time_entries/task/{task_id}/playing", response_model=TimeEntryResponse)
def get_time_entry(task_id: int, db: Session = Depends(get_db)):
    """
    Get the active time entry for a specific task.
    """
    task = db.query(Task).get(task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")

    active_time_entry = db.query(TimeEntry).filter(
        TimeEntry.task_id == task_id, TimeEntry.end_time == None).first()
    if not active_time_entry:
        raise HTTPException(
            status_code=404, detail="No time entry without end time")

    return active_time_entry.to_response_model()


@app.get("/api/docs", include_in_schema=False)
async def custom_swagger_ui_html():
    """
    Custom route for Swagger UI HTML.
    """
    return get_swagger_ui_html(openapi_url="/openapi.json", title="API Docs")


@app.get("/api/openapi.json", include_in_schema=False)
async def get_openapi_json():
    """
    Get the OpenAPI schema in JSON format.
    """
    return app.openapi()


def custom_openapi():
    """
    Custom OpenAPI function to generate the schema.
    """
    if app.openapi_schema:
        return app.openapi_schema


app.mount("/", StaticFiles(directory="ui/time_tracker_ui/build/web", html=True))


if __name__ == "__main__":
    uvicorn.run("main:app", host="127.0.0.1", port=5001, log_level="info")