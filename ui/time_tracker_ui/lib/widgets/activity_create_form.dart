import 'package:flutter/material.dart';

class ActivityCreateForm extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController originalEstimateController =
      TextEditingController();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  final formData = {
                    'name': nameController.text.trim(),
                    'original_estimate': originalEstimateController.text.trim(),
                  };
                  Navigator.of(context).pop(formData);
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
