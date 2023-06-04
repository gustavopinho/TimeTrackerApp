from typing import List
from fastapi import Depends, FastAPI, HTTPException
from fastapi.openapi.docs import get_swagger_ui_html
from fastapi.staticfiles import StaticFiles
from sqlalchemy.orm import Session

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
        completed_hours=0.0
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
    db_activity.remaining_hours = activity.remaining_hours
    db_activity.completed_hours = activity.completed_hours
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
def list_activities(db: Session = Depends(get_db)):
    """
    List all activities.
    """
    activities = db.query(Activity).all()
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
    new_task = Task(
        activity_id=task.activity_id,
        name=task.name,
        start_time=task.start_time,
        end_time=task.end_time,
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
    db_task.start_time = task.start_time
    db_task.end_time = task.end_time
    db_task.duration = task.duration
    db.commit()
    db.refresh(db_task)
    db.close()
    return db_task.to_response_model()


@app.delete("/api/tasks/{task_id}/", status_code=200)
def delete_task(task_id: int, db: Session = Depends(get_db)):
    """
    Delete a task.
    """
    task = db.query(Task).get(task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    db.delete(task)
    db.commit()
    db.close()


@app.get("/api/tasks/activity/{activity_id}/", response_model=List[TaskResponse])
async def list_tasks(activity_id: int, db: Session = Depends(get_db)):
    """
    List tasks of a specific activity.
    """
    # ... implementation ...
    tasks = db.query(Task).filter(Task.activity_id == activity_id).all()
    db.close()
    return [task.to_response_model() for task in tasks]


@app.post("/api/time_entries/", response_model=TimeEntryResponse)
def create_time_entry(time_entry: TimeEntryCreate, db: Session = Depends(get_db)):
    """
    Create a new time entry.
    """
    task = db.query(Task).get(time_entry.task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    start_time = time_entry.start_time
    end_time = time_entry.end_time
    duration = (end_time - start_time).total_seconds() / 3600.0
    new_time_entry = TimeEntry(
        task_id=time_entry.task_id,
        start_time=start_time,
        end_time=end_time,
        duration=duration
    )
    db.add(new_time_entry)
    db.commit()
    db.refresh(new_time_entry)
    db.close()
    return new_time_entry.to_response_model()


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


@app.get("/api/time_entries/", response_model=List[TimeEntryResponse])
async def list_time_entries(task_id: int, db: Session = Depends(get_db)):
    """
    List time entries of a specific task.
    """
    # ... implementation ...
    time_entries = db.query(TimeEntry).filter(TimeEntry.task_id == task_id).all()
    db.close()
    return [time_entry.to_response_model() for time_entry in time_entries]


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
    

app.mount("/", StaticFiles(directory="app-ui/out", html=True))