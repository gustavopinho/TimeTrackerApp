import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:time_tracker_ui/models/task_model.dart';

class TaskRepository {
  final String baseUrl; // Replace this with your API base URL

  TaskRepository(this.baseUrl);

  Future<TaskResponse> createTask(TaskCreate task) async {
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(task.toJson());
    final response = await http.post(Uri.parse('$baseUrl/api/tasks/'),
        headers: headers, body: body);

    if (response.statusCode == 201) {
      return TaskResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create task');
    }
  }

  Future<TaskResponse> getTask(int taskId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/tasks/$taskId/'));

    if (response.statusCode == 200) {
      return TaskResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch task');
    }
  }

  Future<TaskResponse> updateTask(int taskId, TaskUpdate taskUpdate) async {
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(taskUpdate.toJson());
    final response = await http.put(Uri.parse('$baseUrl/api/tasks/$taskId/'),
        headers: headers, body: body);

    if (response.statusCode == 200) {
      return TaskResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update task');
    }
  }

  Future<void> deleteTask(int taskId) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/api/tasks/$taskId/'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }

  Future<TaskResponse> closeTask(int taskId) async {
    final headers = {'Content-Type': 'application/json'};
    final response = await http
        .put(Uri.parse('$baseUrl/api/tasks/close/$taskId/'), headers: headers);

    if (response.statusCode == 200) {
      return TaskResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to close task');
    }
  }

  Future<TimeEntryStartResponse> startTimeEntry(int taskId) async {
    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(
        Uri.parse('$baseUrl/api/time_entries/$taskId/start'),
        headers: headers);

    if (response.statusCode == 200) {
      return TimeEntryStartResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to start time entry');
    }
  }

  Future<TimeEntryResponse> stopTimeEntry(int timeEntryId) async {
    final headers = {'Content-Type': 'application/json'};
    final response = await http.put(
        Uri.parse('$baseUrl/api/time_entries/$timeEntryId/stop'),
        headers: headers);

    if (response.statusCode == 200) {
      return TimeEntryResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to stop time entry');
    }
  }

  Future<TimeEntryResponse> getTimeEntry(int timeEntryId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/time_entries/$timeEntryId/'));

    if (response.statusCode == 200) {
      return TimeEntryResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch time entry');
    }
  }

  Future<TaskListResponse> getTasksForActivity(int activityId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/tasks/activity/$activityId/'));

    if (response.statusCode == 200) {
      return TaskListResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch tasks for activity');
    }
  }

  Future<TimeEntryResponse> createTimeEntry(int taskId) async {
    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(
        Uri.parse('$baseUrl/api/time_entries/$taskId/start'),
        headers: headers);

    if (response.statusCode == 200) {
      return TimeEntryResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create time entry');
    }
  }

  Future<TaskListResponse> getTimeEntriesForTask(int taskId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/time_entries/task/$taskId/'));

    if (response.statusCode == 200) {
      return TaskListResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch time entries for task');
    }
  }

  Future<TimeEntryStartResponse> getActiveTimeEntry(int taskId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/time_entries/task/$taskId/playing'));

    if (response.statusCode == 200) {
      return TimeEntryStartResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch active time entry');
    }
  }
}
