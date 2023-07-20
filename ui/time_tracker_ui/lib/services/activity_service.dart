import 'package:time_tracker_ui/repositories/activity_repository.dart';
import 'package:time_tracker_ui/models/activity_model.dart'; // Import the model class

class ActivityService {
  final ActivityRepository repository;

  ActivityService(this.repository);

  Future<List<ActivityResponse>> getActivities(
      {bool finalized = false, String name = ''}) async {
    return repository.getActivities(finalized: finalized, name: name);
  }

  Future<ActivityResponse> getActivity(int activityId) async {
    return repository.getActivity(activityId);
  }

  Future<ActivityResponse> createActivity(ActivityCreate activity) async {
    return repository.createActivity(activity);
  }

  Future<ActivityResponse> updateActivity(
      int activityId, ActivityUpdate activityUpdate) async {
    return repository.updateActivity(activityId, activityUpdate);
  }

  Future<void> deleteActivity(int activityId) async {
    return repository.deleteActivity(activityId);
  }
}
