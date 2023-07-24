import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_tracker_ui/models/activity_model.dart';

import '../utils/decimal_text_input_formatter.dart';

class ActivityUpdateForm extends StatefulWidget {
  final ActivityResponse activity;

  const ActivityUpdateForm({super.key, required this.activity});

  @override
  State<ActivityUpdateForm> createState() => _ActivityUpdateFormState();
}

class _ActivityUpdateFormState extends State<ActivityUpdateForm> {
  late TextEditingController _nameController;
  late TextEditingController _originalEstimateController;
  late TextEditingController _completedHoursController;
  late TextEditingController _pricePerHourController;

  // Additional properties for the ActivityUpdate model
  late bool _finalized;
  late bool _moneyReceived;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.activity.name);
    _originalEstimateController = TextEditingController(
        text: widget.activity.originalEstimate.toString());
    _completedHoursController =
        TextEditingController(text: widget.activity.completedHours.toString());
    _pricePerHourController =
        TextEditingController(text: widget.activity.pricePerHour.toString());
    _finalized = widget.activity.finalized ?? false;
    _moneyReceived = widget.activity.moneyReceived ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _originalEstimateController,
            decoration: const InputDecoration(labelText: 'Original Estimate'),
            inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _completedHoursController,
            decoration: const InputDecoration(labelText: 'Completed Hours'),
            inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _pricePerHourController,
            decoration: const InputDecoration(labelText: 'Price Per Hour'),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              const Text("Finalized?"),
              Switch(
                value: _finalized,
                onChanged: (bool value) {
                  setState(() {
                    _finalized = value;
                  });
                },
              ),
              const Text("Money received?"),
              Switch(
                value: _moneyReceived,
                onChanged: (bool value) {
                  setState(() {
                    _moneyReceived = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Collect the form data and return the updated activity when the Confirm button is pressed
                  final updatedActivity = ActivityUpdate(
                    name: _nameController.text.trim(),
                    originalEstimate:
                        double.parse(_originalEstimateController.text.trim()),
                    completedHours:
                        double.parse(_completedHoursController.text.trim()),
                    pricePerHour:
                        double.parse(_pricePerHourController.text.trim()),
                    finalized: _finalized,
                    moneyReceived: _moneyReceived,
                  );
                  Navigator.of(context).pop(updatedActivity);
                },
                child: const Text('Confirm'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the modal
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
