// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:taskmanagerr/pages/edit_page.dart';

class TaskDetails extends StatelessWidget {
  final Map<String, dynamic> task;
  final DatabaseReference tasksRef = FirebaseDatabase.instance.ref().child('tasks'); // Reference to tasks in Firebase

  TaskDetails({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          getTaskDetail('taskName'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 2, 56, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Name
            _buildDetailCard(
              icon: Icons.title,
              label: "Task Name",
              content: getTaskDetail('taskName'),
            ),
            const SizedBox(height: 16),

            // Description
            _buildDetailCard(
              icon: Icons.description,
              label: "Description",
              content: getTaskDetail('description'),
            ),
            const SizedBox(height: 16),

            // Deadline
            _buildDetailCard(
              icon: Icons.calendar_today,
              label: "Deadline Date",
              content: getTaskDetail('deadline') != null
                  ? task['deadline'].split('T')[0] // Extract date part
                  : "Not set",
            ),
            const SizedBox(height: 16),

            // Deadline Time
            _buildDetailCard(
              icon: Icons.access_time,
              label: "Deadline Time",
              content: getTaskDetail('deadline') != null
                  ? task['deadline'].split(' ')[1] // Extract time part
                  : "Not set",
            ),
            const SizedBox(height: 16),

            // Priority
            _buildDetailCard(
              icon: Icons.priority_high,
              label: "Priority",
              content: getTaskDetail('priority'),
            ),
            const SizedBox(height: 16),

            // Category
            _buildDetailCard(
              icon: Icons.category,
              label: "Category",
              content: getTaskDetail('category'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                // Navigate to edit page
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditTaskPage(task: task),
                  ),
                );
              },
              icon: const Icon(Icons.edit, color: Colors.blue),
              label: const Text(
                "Edit",
                style: TextStyle(color: Colors.blue),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                _showDeleteConfirmation(context);
              },
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to build the detail cards
  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String content,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(content, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  // Method to get task detail safely
  String getTaskDetail(String key) {
    // Check if the key exists and is not null; if null, return "Not set"
    return (task[key] != null && task[key] is String) ? task[key] : 'Not set';
  }

  // Method to show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Task"),
        content: const Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _deleteTask(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Method to delete the task from Firebase
  void _deleteTask(BuildContext context) async {
    try {
      // Assuming task contains a unique 'id' key for the Firebase document ID
      await tasksRef.child(task['id']).remove();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(); // Close the dialog
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(); // Go back to the previous screen
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task deleted successfully")),
      );
    } catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete task: $error")),
      );
    }
  }
}
