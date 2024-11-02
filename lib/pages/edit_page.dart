import 'package:flutter/material.dart';

class EditTaskPage extends StatefulWidget {
  final Map<String, dynamic> task;

  const EditTaskPage({super.key, required this.task});

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priorityController;
  late TextEditingController _categoryController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.task['taskName']);
    _descriptionController = TextEditingController(text: widget.task['description']);
    _priorityController = TextEditingController(text: widget.task['priority']);
    _categoryController = TextEditingController(text: widget.task['category']);

    final deadlineParts = widget.task['deadline'].split(" ");
    DateTime deadlineDate = DateTime.parse(deadlineParts[0]);
    String formattedDate = "${deadlineDate.day.toString().padLeft(2, '0')}/${(deadlineDate.month).toString().padLeft(2, '0')}/${deadlineDate.year.toString().substring(2)}";

    _dateController = TextEditingController(text: formattedDate);
    _timeController = TextEditingController(text: deadlineParts[1]);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priorityController.dispose();
    _categoryController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(widget.task['deadline'].split(" ")[0]),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year.toString().substring(2)}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.parse("1970-01-01T${widget.task['deadline'].split(" ")[1]}")),
    );
    if (picked != null) {
      setState(() {
        final formattedTime = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00.000";
        _timeController.text = formattedTime;
      });
    }
  }

  Future<void> _updateTask() async {
    try {
      List<String> dateParts = _dateController.text.split("/");
      String formattedForStorage = "20${dateParts[2]}-${dateParts[1]}-${dateParts[0]}T${_timeController.text}";

      // Uncomment and update with your Firebase update logic
      // await FirebaseFirestore.instance.collection('tasks').doc(widget.task['id']).update({
      //   'taskName': _nameController.text,
      //   'description': _descriptionController.text,
      //   'priority': _priorityController.text,
      //   'category': _categoryController.text,
      //   'deadline': formattedForStorage,
      // });

      // If the update is successful
      _showAlert("Task updated successfully!", Colors.green);
      Navigator.of(context).pop();
    } catch (error) {
      // If the update fails
      _showAlert("Failed to update task. Please try again.", Colors.red);
    }
  }

  void _showAlert(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Task"),
        backgroundColor: const Color.fromARGB(255, 2, 56, 255),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenSize.width * 0.05),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Edit Your Task", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: const Color.fromARGB(255, 2, 56, 255), fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTextField(_nameController, "Task Name", Icons.task),
                const SizedBox(height: 16),
                _buildTextField(_descriptionController, "Description", Icons.description, isMultiline: true),
                const SizedBox(height: 16),
                _buildTextField(_priorityController, "Priority", Icons.priority_high),
                const SizedBox(height: 16),
                _buildTextField(_categoryController, "Category", Icons.category),
                const SizedBox(height: 16),
                _buildTextField(_dateController, "Date (dd/MM/yy)", Icons.calendar_today, isReadOnly: true, onTap: () => _selectDate(context)),
                const SizedBox(height: 16),
                _buildTextField(_timeController, "Time (HH:mm:ss.sss)", Icons.access_time, isReadOnly: true, onTap: () => _selectTime(context)),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _updateTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 2, 56, 255),
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Save Changes", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isMultiline = false, bool isReadOnly = false, VoidCallback? onTap}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 2, 56, 255)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromARGB(255, 2, 56, 255)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromARGB(255, 2, 56, 255), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: isMultiline ? 3 : 1,
      readOnly: isReadOnly,
      onTap: onTap,
    );
  }
}
