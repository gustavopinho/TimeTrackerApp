import 'package:flutter/material.dart';
import 'package:time_tracker_ui/repositories/activity_repository.dart';
import 'package:time_tracker_ui/screens/home.screen.dart';
import 'package:time_tracker_ui/services/activity_service.dart';

void main() {
  final String baseUrl =
      'http://localhost:8000'; // Replace with your actual API base URL
  final ActivityRepository activityRepository = ActivityRepository(baseUrl);
  final ActivityService activityService = ActivityService(activityRepository);

  runApp(MyApp(activityService: activityService));
}

class MyApp extends StatelessWidget {
  final ActivityService activityService;

  MyApp({required this.activityService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Tracker', // Replace with your app's name
      home: HomePage(activityService: activityService),
    );
  }
}
