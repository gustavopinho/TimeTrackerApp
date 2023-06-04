from datetime import datetime
from pydantic import BaseModel
from typing import Optional

# Pydantic models for API input/output
class ActivityResponse(BaseModel):
    activity_id: Optional[int]
    name: str
    original_estimate: float
    remaining_hours: float
    completed_hours: float

class TaskResponse(BaseModel):
    task_id: Optional[int]
    activity_id: int
    name: str
    start_time: datetime
    end_time: datetime
    duration: float

class TimeEntryResponse(BaseModel):
    time_entry_id: Optional[int]
    task_id: int
    start_time: datetime
    end_time: datetime

class ActivityCreate(BaseModel):
    name: str
    original_estimate: float

class ActivityUpdate(BaseModel):
    name: str
    original_estimate: float
    remaining_hours: float
    completed_hours: float

class TaskCreate(BaseModel):
    activity_id: int
    name: str
    start_time: datetime
    end_time: datetime

class TaskUpdate(BaseModel):
    name: str
    start_time: datetime
    end_time: datetime
    duration: float

class TimeEntryCreate(BaseModel):
    task_id: int
    start_time: datetime
    end_time: datetime