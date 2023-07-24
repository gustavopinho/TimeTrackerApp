import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:time_tracker_ui/models/activity_model.dart';
import 'package:time_tracker_ui/models/task_model.dart';
import 'package:time_tracker_ui/screens/tasks.screen.dart';
import 'package:time_tracker_ui/services/activity_service.dart';
import 'package:time_tracker_ui/widgets/activity_create_form.dart';
import 'package:time_tracker_ui/widgets/activity_update_form.dart';

import '../services/task_service.dart';

class HomePage extends StatefulWidget {
  final ActivityService activityService;
  final TaskService taskService;

  const HomePage(
      {super.key, required this.activityService, required this.taskService});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ActivityResponse> _activities = [];

  final TextEditingController _nameFilterController = TextEditingController();
  bool _finalizedFilter = false;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  void _loadActivities() async {
    try {
      final activities = await widget.activityService.getActivities();
      setState(() {
        _activities = activities;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading activities: $e');
      }
    }
  }

  void _onFilter() async {
    try {
      if (_nameFilterController.text.trim() == "" &&
          _finalizedFilter == false) {
        _loadActivities();
        return;
      }

      final activities = await widget.activityService.getActivities(
        finalized: _finalizedFilter,
        name: _nameFilterController.text.trim(),
      );

      setState(() {
        _activities = activities;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading activities: $e');
      }
    }
  }

  void _onCreateActivity() async {
    final result = await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
            alignment: Alignment.bottomCenter,
            margin: const EdgeInsets.all(16.0),
            child: ActivityCreateForm());
      },
    );

    if (result != null && result is Map<String, dynamic>) {
      try {
        await widget.activityService
            .createActivity(ActivityCreate.fromMap(result));

        _onFilter();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activity created successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to create activity: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _onUpdateActivity(ActivityResponse activity) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
            alignment: Alignment.bottomCenter,
            margin: const EdgeInsets.all(16.0),
            child: ActivityUpdateForm(activity: activity));
      },
    );

    if (result != null && result is ActivityUpdate) {
      try {
        await widget.activityService
            .updateActivity(activity.activityId, result);

        _onFilter();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Activity updated successfully.'),
          backgroundColor: Colors.green,
        ));
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update activity: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _onViewActivityTasks(ActivityResponse activity) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            TasksPage(taskService: widget.taskService, activity: activity)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activities')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nameFilterController,
              decoration: const InputDecoration(
                labelText: 'Filter by Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _onFilter(),
            ),
          ),
          SwitchListTile(
            title: const Text('Finalized Only'),
            value: _finalizedFilter,
            onChanged: (bool value) => {
              setState(() {
                _finalizedFilter = value;
              }),
              _onFilter()
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                final activity = _activities[index];
                return ListTile(
                  title: Text(activity.name),
                  subtitle: Text(
                      'Original estimate: ${activity.originalEstimate}, Remaining Hours: ${activity.remainingHours}, Completed Hours: ${activity.completedHours}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _onUpdateActivity(activity),
                      ),
                      IconButton(
                        icon: const Icon(Icons.list),
                        onPressed: () => _onViewActivityTasks(activity),
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
        onPressed: _onCreateActivity,
        child: const Icon(Icons.add),
      ),
    );
  }
}
