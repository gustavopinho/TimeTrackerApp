class TaskCreate {
  final int activityId;
  final String name;

  TaskCreate(this.activityId, this.name);

  Map<String, dynamic> toJson() {
    return {'activity_id': activityId, 'name': name};
  }
}

class TaskUpdate {
  final String name;

  TaskUpdate(this.name);

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}

class TaskResponse {
  final int taskId;
  final int activityId;
  final String name;
  final String? startTime;
  final String? endTime;
  final double? duration;
  final bool? closed;

  TaskResponse(
      {required this.taskId,
      required this.activityId,
      required this.name,
      required this.startTime,
      required this.endTime,
      required this.duration,
      required this.closed});

  factory TaskResponse.fromJson(Map<String, dynamic> json) {
    return TaskResponse(
        taskId: json['task_id'],
        activityId: json['activity_id'],
        name: json['name'],
        startTime: json['start_time'],
        endTime: json['end_time'],
        duration: json['duration'],
        closed: json['closed']);
  }
}

class TimeEntryResponse {
  final int timeEntryId;
  final int taskId;
  final String? startTime;
  final String? endTime;

  TimeEntryResponse({
    required this.timeEntryId,
    required this.taskId,
    required this.startTime,
    required this.endTime,
  });

  factory TimeEntryResponse.fromJson(Map<String, dynamic> json) {
    return TimeEntryResponse(
      timeEntryId: json['time_entry_id'],
      taskId: json['task_id'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}

class TaskListResponse {
  final List<TaskResponse> tasks;

  TaskListResponse({required this.tasks});

  factory TaskListResponse.fromJson(List<dynamic> json) {
    return TaskListResponse(
      tasks: json.map((data) => TaskResponse.fromJson(data)).toList(),
    );
  }

  get length => null;
}

class TimeEntryStartResponse {
  final int timeEntryId;
  final int taskId;
  final String? startTime;

  TimeEntryStartResponse({
    required this.timeEntryId,
    required this.taskId,
    required this.startTime,
  });

  factory TimeEntryStartResponse.fromJson(Map<String, dynamic> json) {
    return TimeEntryStartResponse(
      timeEntryId: json['time_entry_id'],
      taskId: json['task_id'],
      startTime: json['start_time'],
    );
  }
}
