from sqlalchemy import Boolean, create_engine, Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import declarative_base, sessionmaker, relationship

from models import ActivityResponse, TaskResponse, TimeEntryResponse

# SQLAlchemy models
Base = declarative_base()


def get_formmated_datetime(date):
    if date is not None:
        return date.strftime("%Y-%m-%d %H:%M")
    return None


def get_round(value):
    if value is not None:
        return round(value, 2)
    return None


class Activity(Base):
    __tablename__ = "activities"

    activity_id = Column(Integer, primary_key=True)
    name = Column(String(255))
    original_estimate = Column(Float)
    remaining_hours = Column(Float)
    completed_hours = Column(Float)
    finalized = Column(Boolean)
    price_per_hour = Column(Float)
    money_received = Column(Boolean)

    tasks = relationship("Task", back_populates="activity")

    def to_response_model(self) -> ActivityResponse:
        return ActivityResponse(
            activity_id=self.activity_id,
            name=self.name,
            original_estimate=self.original_estimate,
            remaining_hours=get_round(self.remaining_hours),
            completed_hours=get_round(self.completed_hours),
            finalized=self.finalized,
            price_per_hour=self.price_per_hour,
            money_received=self.money_received
        )


class Task(Base):
    __tablename__ = "tasks"

    task_id = Column(Integer, primary_key=True)
    activity_id = Column(Integer, ForeignKey("activities.activity_id"))
    name = Column(String(255))
    start_time = Column(DateTime, nullable=True)
    end_time = Column(DateTime, nullable=True)
    duration = Column(Float)
    closed = Column(Boolean)

    activity = relationship(Activity)
    time_entries = relationship("TimeEntry", back_populates="task")

    def to_response_model(self) -> TaskResponse:
        return TaskResponse(
            task_id=self.task_id,
            activity_id=self.activity_id,
            name=self.name,
            start_time=get_formmated_datetime(self.start_time),
            end_time=get_formmated_datetime(self.end_time),
            duration=round(self.duration, 2),
            closed=self.closed
        )


class TimeEntry(Base):
    __tablename__ = "time_entries"

    time_entry_id = Column(Integer, primary_key=True)
    task_id = Column(Integer, ForeignKey("tasks.task_id", ondelete="CASCADE"))
    start_time = Column(DateTime)
    end_time = Column(DateTime, nullable=True)
    duration = Column(Float, nullable=True)

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
