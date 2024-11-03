import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskmanagerr/services/database/edit_task_page.dart';
import 'package:taskmanagerr/services/database/task_service.dart'; // Ensure this import points to your TaskService

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

  final List<String> categories = ["Select Category", "Assignment", "Project", "Study", "Personal"];
  final List<String> priorities = ["Select Priority", "High", "Medium", "Low"];

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController(text: widget.task['taskName'] ?? '');
    _descriptionController = TextEditingController(text: widget.task['description'] ?? '');
    _deadlineController = TextEditingController(text: widget.task['deadline'] ?? '');
    _selectedPriority = widget.task['priority'] ?? 'Medium';
    _selectedCategory = widget.task['category'] ?? 'General';
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        setState(() {
          _deadlineController.text =
              "${DateFormat('yyyy-MM-dd').format(selectedDate)} ${selectedTime.hour}:${selectedTime.minute}";
        });
      }
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final updatedTask = {
        'taskName': _taskNameController.text.isNotEmpty ? _taskNameController.text : "No Task Name",
        'description': _descriptionController.text.isNotEmpty ? _descriptionController.text : "No Description",
        'deadline': _deadlineController.text.isNotEmpty ? _deadlineController.text : "No Deadline",
        'priority': _selectedPriority != null && _selectedPriority != "Select Priority" ? _selectedPriority : "Medium",
        'category': _selectedCategory != null && _selectedCategory != "Select Category" ? _selectedCategory : "General",
      };

      try {
        await TaskService().updateTask(widget.task['id'], updatedTask);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Task updated successfully")),
        );
      } catch (e) {
        _showErrorDialog("Failed to update task: $e");
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
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
                icon: Icons.title,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDeadline(context),
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: _deadlineController,
                    label: 'Deadline (YYYY-MM-DD HH:mm)',
                    icon: Icons.calendar_today,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Priority',
                value: _selectedPriority,
                items: priorities,
                icon: Icons.priority_high,
                onChanged: (newValue) {
                  setState(() {
                    _selectedPriority = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Category',
                value: _selectedCategory,
                items: categories,
                icon: Icons.category,
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveTask,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, color: const Color.fromARGB(255, 2, 56, 255)),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color.fromARGB(255, 2, 56, 255)),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            value: value,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (value) {
              if (value == null || value == "Select $label") {
                return 'Please select a $label';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
