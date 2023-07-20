import 'package:flutter/material.dart';
import 'package:time_tracker_ui/models/activity_model.dart';
import 'package:time_tracker_ui/services/activity_service.dart';
import 'package:time_tracker_ui/widgets/activity_create_form.dart';
import 'package:time_tracker_ui/widgets/activity_update_form.dart';

class HomePage extends StatefulWidget {
  final ActivityService activityService;

  HomePage({required this.activityService});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ActivityResponse> _activities = [];
  TextEditingController _nameFilterController = TextEditingController();
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
      // Handle error
      print('Error loading activities: $e');
    }
  }

  void _onFilter() async {
    try {
      final activities = await widget.activityService.getActivities(
        finalized: !_finalizedFilter,
        name: _nameFilterController.text.trim(),
      );
      setState(() {
        _activities = activities;
        _finalizedFilter = !_finalizedFilter;
      });
    } catch (e) {
      // Handle error
      print('Error loading activities: $e');
    }
  }

  void _onCreateActivity() async {
    final result = await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(16.0),
            child: ActivityCreateForm());
      },
    );

    if (result != null && result is Map<String, dynamic>) {
      try {
        final createdActivity = await widget.activityService
            .createActivity(ActivityCreate.fromMap(result));

        _loadActivities();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Activity created successfully.'),
        ));
      } catch (e) {
        // Handle API call error
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
            alignment: Alignment.center,
            margin: EdgeInsets.all(16.0),
            child: ActivityUpdateForm(activity: activity));
      },
    );

    // The `result` variable will contain the updated activity if the user confirmed the update
    if (result != null && result is ActivityUpdate) {
      try {
        // Assuming you have the updateActivity method in your TaskService
        await widget.activityService
            .updateActivity(activity.activityId, result);

        _loadActivities();

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Activity updated successfully.'),
        ));
      } catch (e) {
        // Handle API call error
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update activity: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _onViewActivityTasks(ActivityResponse activity) {
    // Implement logic to navigate to activity tasks list screen here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Activities')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nameFilterController,
              decoration: InputDecoration(
                labelText: 'Filter by Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _onFilter(),
            ),
          ),
          SwitchListTile(
            title: Text('Finalized Only'),
            value: _finalizedFilter,
            onChanged: (_) => _onFilter(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                final activity = _activities[index];
                return ListTile(
                  title: Text(activity.name),
                  subtitle: Text(
                      'Remaining Hours: ${activity.remainingHours}, Completed Hours: ${activity.completedHours}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _onUpdateActivity(activity),
                      ),
                      IconButton(
                        icon: Icon(Icons.list),
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
        child: Icon(Icons.add),
      ),
    );
  }
}
