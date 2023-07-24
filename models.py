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
    finalized: Optional[bool]
    price_per_hour: Optional[float]
    money_received: Optional[bool]


class TaskResponse(BaseModel):
    task_id: Optional[int]
    activity_id: int
    name: str
    start_time: Optional[datetime]
    end_time: Optional[datetime]
    duration: float
    closed: Optional[bool]


class TimeEntryResponse(BaseModel):
    time_entry_id: Optional[int]
    task_id: int
    start_time: datetime
    end_time:  Optional[datetime]


class ActivityCreate(BaseModel):
    name: str
    original_estimate: float


class ActivityUpdate(BaseModel):
    name: str
    original_estimate: float
    completed_hours: float
    finalized: bool
    price_per_hour: float
    money_received: bool


class TaskCreate(BaseModel):
    activity_id: int
    name: str


class TaskUpdate(BaseModel):
    name: str


class TimeEntryCreate(BaseModel):
    task_id: int
    start_time: datetime
    end_time: datetime
