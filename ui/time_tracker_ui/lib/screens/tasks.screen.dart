import 'dart:async';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:time_tracker_ui/models/activity_model.dart';
import 'package:time_tracker_ui/models/task_model.dart';
import 'package:time_tracker_ui/widgets/task_create_form.dart';
import 'package:time_tracker_ui/widgets/task_update_form.dart';

import '../services/task_service.dart';

class TasksPage extends StatefulWidget {
  final TaskService taskService;
  final ActivityResponse activity;

  const TasksPage(
      {super.key, required this.taskService, required this.activity});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String _title = '';
  List<TaskResponse> _tasks = [];
  TimeEntryStartResponse? _timeEntry;

  Timer? countUpTimer;
  Duration myDuration = Duration(seconds: 0);

  @override
  void initState() {
    super.initState();
    _setTitle();
    _loadTasks();
  }

  void _startTimer(TimeEntryStartResponse timeEntry) {
    final DateTime startTime = DateTime.parse(timeEntry.startTime!);

    final duration =
        Duration(seconds: DateTime.now().difference(startTime).inSeconds);
    final timer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountUp());

    _stopTimer();

    setState(() {
      myDuration = duration;
      countUpTimer = timer;
    });
  }

  void _stopTimer() {
    if (countUpTimer != null) {
      setState(() => countUpTimer!.cancel());
    }
  }

  void setCountUp() {
    const increaseSecondsBy = 1;

    if (!mounted) return;

    if (_timeEntry == null) _stopTimer();

    setState(() {
      final seconds = myDuration.inSeconds + increaseSecondsBy;
      myDuration = Duration(seconds: seconds);
    });
  }

  void _setTitle() {
    setState(() {
      _title =
          'Activity: ${widget.activity.activityId} - ${widget.activity.name}';
    });
  }

  void _loadTasks() async {
    try {
      final resp = await widget.taskService
          .getTasksForActivity(widget.activity.activityId);

      for (var e in resp.tasks) {
        try {
          final timeEntry =
              await widget.taskService.getActiveTimeEntry(e.taskId);
          setState(() {
            _timeEntry = TimeEntryStartResponse(
                timeEntryId: timeEntry.timeEntryId,
                taskId: timeEntry.taskId,
                startTime: timeEntry.startTime);
          });
          _startTimer(timeEntry);
          break;
        } catch (e) {}
      }

      setState(() {
        _tasks = resp.tasks;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading tasks: $e');
      }
    }
  }

  void _onCreateTask() async {
    final result = await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
            alignment: Alignment.bottomCenter,
            margin: const EdgeInsets.all(16.0),
            child: TaskCreateForm());
      },
    );

    if (result != null && result is Map<String, dynamic>) {
      try {
        final task =
            TaskCreate(widget.activity.activityId, result['name'] as String);
        await widget.taskService.createTask(task);

        _loadTasks();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to create task: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _onUpdateTask(TaskResponse task) async {
    final result = await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
            alignment: Alignment.bottomCenter,
            margin: const EdgeInsets.all(16.0),
            child: TaskUpdateForm(task: task));
      },
    );

    if (result != null && result is Map<String, dynamic>) {
      try {
        final taskToUpdate = TaskUpdate(result['name'] as String);

        await widget.taskService.updateTask(task.activityId, taskToUpdate);

        _loadTasks();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Task updated successfully.'),
          backgroundColor: Colors.green,
        ));
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update task: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _onDeleteTask(TaskResponse task) async {
    try {
      await widget.taskService.deleteTask(task.taskId);

      _loadTasks();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Task deleted successfully.'),
        backgroundColor: Colors.green,
      ));

      if (_timeEntry == null) {
        return;
      }

      if (task.taskId != _timeEntry!.taskId) {
        return;
      }
      _stopTimer();

      setState(() {
        _timeEntry = null;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to delete task: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _startTask(TaskResponse task) async {
    try {
      final timeEntry = await widget.taskService.startTimeEntry(task.taskId);

      _loadTasks();

      _startTimer(timeEntry);

      setState(() {
        _timeEntry = timeEntry;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to start time entry: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _stopTask() async {
    try {
      if (_timeEntry != null) {
        final timeEntryId = _timeEntry!.timeEntryId;
        await widget.taskService.stopTimeEntry(timeEntryId);

        _stopTimer();

        setState(() {
          _timeEntry = null;
        });

        _loadTasks();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Task closed successfully.'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to stop time entry: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _closeTask(TaskResponse task) async {
    try {
      await widget.taskService.closeTask(task.taskId);
      _loadTasks();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to close task: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');

    final hours = strDigits(myDuration.inHours.remainder(24));
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));

    return Scaffold(
        appBar: AppBar(
          title: Text(_timeEntry != null
              ? "Tasks (Running ID ${_timeEntry!.taskId}: $hours:$minutes:$seconds)"
              : "Tasks"),
        ),
        body: Column(
          children: [
            const SizedBox(width: 4),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(_title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 15)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return ListTile(
                    title: Text((_timeEntry != null &&
                            _timeEntry?.taskId == task.taskId)
                        ? 'ID ${task.taskId}: ${task.name} [$hours:$minutes:$seconds]'
                        : 'ID ${task.taskId}: ${task.name}'),
                    subtitle: Text(
                        'Started at: ${task.startTime} Fineshed at: ${task.endTime} Duration: ${task.duration}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Visibility(
                          visible: task.closed != true && _timeEntry == null,
                          child: IconButton(
                            icon: const Icon(Icons.play_circle),
                            color: Colors.green,
                            onPressed: () => _startTask(task),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Visibility(
                          visible: task.closed != true &&
                              _timeEntry != null &&
                              _timeEntry?.taskId == task.taskId,
                          child: IconButton(
                            icon: const Icon(Icons.stop_circle),
                            color: Colors.black,
                            onPressed: () => _stopTask(),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Visibility(
                          visible: task.closed != true,
                          child: IconButton(
                            icon: const Icon(Icons.archive),
                            color: Colors.blueAccent,
                            onPressed: () => _closeTask(task),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          color: Colors.orangeAccent,
                          onPressed: () => _onUpdateTask(task),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () => _onDeleteTask(task),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _onCreateTask(),
          child: const Icon(Icons.add),
        ));
  }
}
