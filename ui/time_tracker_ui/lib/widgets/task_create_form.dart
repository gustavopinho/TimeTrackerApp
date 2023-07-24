import 'package:flutter/material.dart';

class TaskCreateForm extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();

  TaskCreateForm({super.key});

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
