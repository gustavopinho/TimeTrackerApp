import 'package:flutter/material.dart';
import 'package:time_tracker_ui/models/activity_model.dart';

class ActivityUpdateForm extends StatelessWidget {
  final ActivityResponse activity;
  final TextEditingController nameController;
  final TextEditingController originalEstimateController;
  final TextEditingController completedHoursController;
  final TextEditingController pricePerHourController;

  // Additional properties for the ActivityUpdate model
  final TextEditingController finalizedController;
  final TextEditingController moneyReceivedController;

  ActivityUpdateForm({required this.activity})
      : nameController = TextEditingController(text: activity.name),
        originalEstimateController =
            TextEditingController(text: activity.originalEstimate.toString()),
        completedHoursController =
            TextEditingController(text: activity.completedHours.toString()),
        pricePerHourController =
            TextEditingController(text: activity.pricePerHour.toString()),
        finalizedController =
            TextEditingController(text: activity.finalized.toString()),
        moneyReceivedController =
            TextEditingController(text: activity.moneyReceived.toString());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: originalEstimateController,
            decoration: InputDecoration(labelText: 'Original Estimate'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: completedHoursController,
            decoration: InputDecoration(labelText: 'Completed Hours'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: pricePerHourController,
            decoration: InputDecoration(labelText: 'Price Per Hour'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: finalizedController,
            decoration: InputDecoration(labelText: 'Finalized'),
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: moneyReceivedController,
            decoration: InputDecoration(labelText: 'Money Received'),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Collect the form data and return the updated activity when the Confirm button is pressed
                  final updatedActivity = ActivityUpdate(
                    name: nameController.text.trim(),
                    originalEstimate:
                        double.parse(originalEstimateController.text.trim()),
                    completedHours:
                        double.parse(completedHoursController.text.trim()),
                    pricePerHour:
                        double.parse(pricePerHourController.text.trim()),
                    finalized:
                        finalizedController.text.trim().toLowerCase() == 'true',
                    moneyReceived:
                        moneyReceivedController.text.trim().toLowerCase() ==
                            'true',
                  );
                  Navigator.of(context).pop(updatedActivity);
                },
                child: Text('Confirm'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the modal
                },
                child: Text('Cancel'),
                style: ElevatedButton.styleFrom(primary: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
