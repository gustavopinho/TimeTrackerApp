import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:time_tracker_ui/models/activity_model.dart'; // Import the model class

class ActivityRepository {
  final String baseUrl; // Replace this with your API base URL

  ActivityRepository(this.baseUrl);

  Future<List<ActivityResponse>> getActivities(
      {bool finalized = false, String name = ''}) async {
    final queryParams = {'finalized': finalized.toString(), 'name': name};
    final queryString = Uri(queryParameters: queryParams).query;
    final url = '$baseUrl/api/activities/?$queryString';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body) as List<dynamic>;
      return responseData
          .map((json) => ActivityResponse.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to fetch activities');
    }
  }

  Future<ActivityResponse> getActivity(int activityId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/activities/$activityId/'));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      return ActivityResponse.fromJson(responseData);
    } else {
      throw Exception('Failed to fetch activity');
    }
  }

  Future<ActivityResponse> createActivity(ActivityCreate activity) async {
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(activity.toJson());
    final response = await http.post(Uri.parse('$baseUrl/api/activities/'),
        headers: headers, body: body);

    if (response.statusCode == 201) {
      return ActivityResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create activity');
    }
  }

  Future<ActivityResponse> updateActivity(
      int activityId, ActivityUpdate activityUpdate) async {
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(activityUpdate.toJson());
    final response = await http.put(
        Uri.parse('$baseUrl/api/activities/$activityId/'),
        headers: headers,
        body: body);

    if (response.statusCode == 200) {
      return ActivityResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update activity');
    }
  }

  Future<void> deleteActivity(int activityId) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/api/activities/$activityId/'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete activity');
    }
  }
}
