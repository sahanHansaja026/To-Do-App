import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:taskmanagerr/services/database/edit_task_page.dart';


class EditTaskPage extends StatefulWidget {
  final Map<String, dynamic> task;

  const EditTaskPage({super.key, required this.task});

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _taskNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _deadlineController;
  String? _selectedPriority;
  String? _selectedCategory;

  final List<String> categories = [
    "Select Category",
    "Assignment",
    "Project",
    "Study",
    "Personal"
  ];
  final List<String> priorities = ["Select Priority", "High", "Medium", "Low"];

  bool _isLoading = false; // Loading indicator state
  final TaskService _taskService = TaskService(); // Instantiate TaskService

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController(text: widget.task['taskName']);
    _descriptionController = TextEditingController(text: widget.task['description']);
    _deadlineController = TextEditingController(text: widget.task['deadline']);
    _selectedPriority = widget.task['priority'];
    _selectedCategory = widget.task['category'];
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        backgroundColor: const Color.fromARGB(255, 2, 56, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _taskNameController,
                label: 'Task Name',
                icon: Icons.task,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
              ),
              const SizedBox(height: 16),
              _buildDateTimeField(),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Priority',
                value: _selectedPriority,
                items: priorities,
                onChanged: (newValue) {
                  setState(() {
                    _selectedPriority = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Category',
                value: _selectedCategory,
                items: categories,
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveTask,
                      child: const Text('Save Changes'),
                    ),
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
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildDateTimeField() {
    return TextFormField(
      controller: _deadlineController,
      decoration: InputDecoration(
        labelText: 'Deadline',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: _selectDateTime,
        ),
      ),
      readOnly: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a deadline';
        }
        return null;
      },
    );
  }

  Future<void> _selectDateTime() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        final DateTime dateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        _deadlineController.text = dateTime.toString();
      }
    }
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value == "Select $label") {
          return 'Please select $label';
        }
        return null;
      },
    );
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Start loading
      });

      final updatedTask = {
        'taskName': _taskNameController.text,
        'description': _descriptionController.text,
        'deadline': _deadlineController.text,
        'priority': _selectedPriority,
        'category': _selectedCategory,
      };

      try {
        await _taskService.updateTask(widget.task['id'], updatedTask);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Task updated successfully")),
        );
      } catch (e) {
        _showErrorDialog("Failed to update task: $e");
      } finally {
        setState(() {
          _isLoading = false; // Stop loading
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
