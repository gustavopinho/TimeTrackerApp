import 'dart:io';

import 'package:flutter/material.dart';
import 'package:time_tracker_ui/app_theme.dart';
import 'package:time_tracker_ui/repositories/activity_repository.dart';
import 'package:time_tracker_ui/repositories/task_repository.dart';
import 'package:time_tracker_ui/screens/home.screen.dart';
import 'package:time_tracker_ui/services/activity_service.dart';
import 'package:time_tracker_ui/services/task_service.dart';
import 'package:window_size/window_size.dart';

void main() {
  const String baseUrl = 'http://localhost:8000';
  final ActivityRepository activityRepository = ActivityRepository(baseUrl);
  final ActivityService activityService = ActivityService(activityRepository);

  final TaskRepository taskRepository = TaskRepository(baseUrl);
  final TaskService taskService = TaskService(taskRepository);

  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Timer Tracker');
  }

  runApp(MyApp(activityService: activityService, taskService: taskService));
}

class MyApp extends StatelessWidget {
  final ActivityService activityService;
  final TaskService taskService;

  const MyApp(
      {super.key, required this.activityService, required this.taskService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Tracker',
      home:
          HomePage(activityService: activityService, taskService: taskService),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: AppTheme.textTheme,
        platform: TargetPlatform.windows,
      ),
    );
  }
}
