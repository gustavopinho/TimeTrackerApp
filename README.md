## Time Tracker App

The Time Tracker app is a web-based application that allows users to track and manage their activities, tasks, and time entries. It provides features to create, update, delete, list, and get details of activities, tasks, and time entries.

### Features

- **Activities Management**: Users can create, update, delete, list, and get details of activities. Each activity has a name, original estimate, remaining hours, and completed hours.

- **Tasks Management**: Users can create, update, delete, list, and get details of tasks. Each task is associated with an activity and has a name, start time, end time, and duration.

- **Time Entries Management**: Users can create, list, and get details of time entries. Each time entry is associated with a task and represents the duration of time spent on that task.

### Endpoints

- `POST /activities/`: Create a new activity.
- `GET /activities/{activity_id}/`: Get details of a specific activity.
- `PUT /activities/{activity_id}/`: Update an existing activity.
- `DELETE /activities/{activity_id}/`: Delete an activity.
- `GET /activities/`: List all activities.

- `POST /tasks/`: Create a new task.
- `GET /tasks/{task_id}/`: Get details of a specific task.
- `PUT /tasks/{task_id}/`: Update an existing task.
- `DELETE /tasks/{task_id}/`: Delete a task.
- `GET /tasks/?activity_id={activity_id}`: List tasks of a specific activity.

- `POST /time_entries/`: Create a new time entry.
- `GET /time_entries/{time_entry_id}/`: Get details of a specific time entry.
- `GET /time_entries/?task_id={task_id}`: List time entries of a specific task.

### Technologies Used

The Time Tracker app is built using the following technologies:

- **Backend Framework**: FastAPI
- **Database**: SQLite
- **API Documentation**: Swagger UI
- **Testing Framework**: Pytest

### Setup and Deployment

To run the Time Tracker app locally, follow these steps:

1. Clone the project repository from GitHub.
2. Install the required dependencies specified in the `requirements.txt` file.
3. Configure the database connection in the `database.py` file.
4. Run the FastAPI server using the command `uvicorn main:app --reload`.
5. Access the app's endpoints using a web browser or an API testing tool like Postman.

For deployment, the app can be hosted on a suitable web server or cloud platform with support for Python applications. Ensure to set up the necessary environment variables and configure the database connection for the deployed environment.
