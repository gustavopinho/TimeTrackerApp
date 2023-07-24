import 'package:time_tracker_ui/models/task_model.dart';
import 'package:time_tracker_ui/repositories/task_repository.dart';

class TaskService {
  final TaskRepository repository;

  TaskService(this.repository);

  Future<TaskResponse> createTask(TaskCreate task) async {
    return repository.createTask(task);
  }

  Future<TaskResponse> getTask(int taskId) async {
    return repository.getTask(taskId);
  }

  Future<TaskResponse> updateTask(int taskId, TaskUpdate taskUpdate) async {
    return repository.updateTask(taskId, taskUpdate);
  }

  Future<void> deleteTask(int taskId) async {
    return repository.deleteTask(taskId);
  }

  Future<TaskResponse> closeTask(int taskId) async {
    return repository.closeTask(taskId);
  }

  Future<TimeEntryStartResponse> startTimeEntry(int taskId) async {
    return repository.startTimeEntry(taskId);
  }

  Future<TimeEntryResponse> stopTimeEntry(int timeEntryId) async {
    return repository.stopTimeEntry(timeEntryId);
  }

  Future<TimeEntryResponse> getTimeEntry(int timeEntryId) async {
    return repository.getTimeEntry(timeEntryId);
  }

  Future<TaskListResponse> getTasksForActivity(int activityId) async {
    return repository.getTasksForActivity(activityId);
  }

  Future<TimeEntryResponse> createTimeEntry(int taskId) async {
    return repository.createTimeEntry(taskId);
  }

  Future<TaskListResponse> getTimeEntriesForTask(int taskId) async {
    return repository.getTimeEntriesForTask(taskId);
  }

  Future<TimeEntryStartResponse> getActiveTimeEntry(int taskId) async {
    return repository.getActiveTimeEntry(taskId);
  }
}
