from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import declarative_base, sessionmaker, relationship, Session

from models import ActivityResponse, TaskResponse, TimeEntryResponse

# SQLAlchemy models
Base = declarative_base()


class Activity(Base):
    __tablename__ = "activities"

    activity_id = Column(Integer, primary_key=True)
    name = Column(String(255))
    original_estimate = Column(Float)
    remaining_hours = Column(Float)
    completed_hours = Column(Float)
    tasks = relationship("Task", back_populates="activity")

    def to_response_model(self) -> ActivityResponse:
        return ActivityResponse(
            activity_id=self.activity_id,
            name=self.name,
            original_estimate=self.original_estimate,
            remaining_hours=self.remaining_hours,
            completed_hours=self.completed_hours
        )


class Task(Base):
    __tablename__ = "tasks"

    task_id = Column(Integer, primary_key=True)
    activity_id = Column(Integer, ForeignKey("activities.activity_id"))
    name = Column(String(255))
    start_time = Column(DateTime)
    end_time = Column(DateTime)
    duration = Column(Float)

    activity = relationship(Activity)

    def to_response_model(self) -> TaskResponse:
        return TaskResponse(
            task_id=self.task_id,
            activity_id=self.activity_id,
            name=self.name,
            start_time=self.start_time,
            end_time=self.end_time,
            duration=self.duration
        )


class TimeEntry(Base):
    __tablename__ = "time_entries"

    time_entry_id = Column(Integer, primary_key=True)
    task_id = Column(Integer, ForeignKey("tasks.task_id"))
    start_time = Column(DateTime)
    end_time = Column(DateTime)
    duration = Column(Float)

    task = relationship(Task)

    def to_response_model(self) -> TimeEntryResponse:
        return TimeEntryResponse(
            time_entry_id=self.time_entry_id,
            task_id=self.task_id,
            start_time=self.start_time,
            end_time=self.end_time
        )


# Database setup
engine = create_engine("sqlite:///time_tracker.db")
Base.metadata.create_all(bind=engine)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
