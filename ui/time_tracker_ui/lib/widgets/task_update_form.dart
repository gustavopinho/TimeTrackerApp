import 'package:flutter/material.dart';
import 'package:time_tracker_ui/models/task_model.dart';

class TaskUpdateForm extends StatelessWidget {
  final TaskResponse task;
  final TextEditingController nameController;

  TaskUpdateForm({super.key, required this.task})
      : nameController = TextEditingController(text: task.name);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                final formData = {
                  'name': nameController.text.trim(),
                };
                Navigator.of(context).pop(formData);
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
      ]),
    );
  }
}
