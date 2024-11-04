import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditTaskPage extends StatefulWidget {
  final Map<String, dynamic> task;

  const EditTaskPage({super.key, required this.task});

  @override
  // ignore: library_private_types_in_public_api
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _deadlineController;

  String _selectedCategory = "Select Category";
  String _selectedPriority = "Select Priority";

  final List<String> categories = [
    "Select Category",
    "Assignment",
    "Project",
    "Study",
    "Personal"
  ];
  final List<String> priorities = ["Select Priority", "High", "Medium", "Low"];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.task['taskName'] ?? '');
    _descriptionController =
        TextEditingController(text: widget.task['description'] ?? '');
    _deadlineController =
        TextEditingController(text: widget.task['deadline'] ?? '');

    _selectedCategory = widget.task['category'] ?? "Select Category";
    _selectedPriority = widget.task['priority'] ?? "Select Priority";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (date != null) {
      TimeOfDay? time = await showTimePicker(
        // ignore: use_build_context_synchronously
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        DateTime dateTime =
            DateTime(date.year, date.month, date.day, time.hour, time.minute);
        _deadlineController.text =
            dateTime.toIso8601String().substring(0, 19).replaceFirst('T', ' ');
      }
    }
  }

  void _updateTask() async {
    String taskId = widget.task['taskId'];
    Map<String, dynamic> updatedTask = {
      'taskName': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'deadline': _deadlineController.text.trim(),
      'priority': _selectedPriority,
      'category': _selectedCategory,
    };

    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskId)
          .update(updatedTask);
      Fluttertoast.showToast(
        msg: "Task updated successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to update task: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Task",style: TextStyle(
          fontWeight: FontWeight.bold,
        ),),
        backgroundColor: const Color.fromARGB(255, 2, 56, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(
                  controller: _nameController,
                  label: "Task Name",
                  icon: Icons.title),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: "Description",
                icon: Icons.description,
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _deadlineController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Deadline",
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onTap: _pickDeadline,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                items: priorities.map((priority) {
                  return DropdownMenuItem(
                      value: priority, child: Text(priority));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value ?? "Select Priority";
                  });
                },
                decoration: InputDecoration(
                  labelText: "Priority",
                  prefixIcon: const Icon(Icons.priority_high),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: categories.map((category) {
                  return DropdownMenuItem(
                      value: category, child: Text(category));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value ?? "Select Category";
                  });
                },
                decoration: InputDecoration(
                  labelText: "Category",
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _updateTask,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: const Color.fromARGB(255, 43, 125, 239),
                ),
                child: const Text(
                  "Update Task",
                  style: TextStyle(
                    color: Colors.white, // Set the text color here
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
