import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:random_string/random_string.dart';
import 'package:taskmanagerr/services/database/database_methods.dart';

class StudentTaskManager extends StatefulWidget {
  const StudentTaskManager({super.key});

  @override
  State<StudentTaskManager> createState() => _StudentTaskManagerState();
}

class _StudentTaskManagerState extends State<StudentTaskManager> {
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDeadline;
  TimeOfDay? selectedTime;  // Variable to hold selected time

  String selectedPriority = "Select Priority";
  String selectedCategory = "Select Category";
  int currentStep = 0;

  final List<String> categories = ["Select Category", "Assignment", "Project", "Study", "Personal"];
  final List<String> priorities = ["Select Priority", "High", "Medium", "Low"];

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Adding Task..."),
              ],
            ),
          ),
        );
      },
    );
  }

  void clearFields() {
    taskNameController.clear();
    descriptionController.clear();
    setState(() {
      selectedDeadline = null;
      selectedTime = null;  // Clear the selected time
      selectedPriority = "Select Priority";
      selectedCategory = "Select Category";
      currentStep = 0;
    });
  }

  Future<void> selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDeadline) {
      setState(() {
        selectedDeadline = picked;
      });
    }
  }

  Future<void> selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;  // Store the selected time
      });
    }
  }

  void nextStep() {
    if (currentStep < 5) {
      setState(() {
        currentStep++;
      });
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  Future<void> submitTask() async {
    showLoadingDialog(context);
    try {
      String id = randomAlphaNumeric(10);
      String? deadline = selectedDeadline != null 
          ? "${selectedDeadline!.toIso8601String()} ${selectedTime?.hour}:${selectedTime?.minute}" 
          : null;

      Map<String, dynamic> taskInfoMap = {
        "taskName": taskNameController.text,
        "description": descriptionController.text,
        "deadline": deadline,
        "priority": selectedPriority,
        "category": selectedCategory,
        "taskId": id,
      };

      await DatabaseMethod().addTaskDetails(taskInfoMap, id).then((value) {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: "Task added successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        clearFields();
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: avoid_print
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add New Task",
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 2, 56, 255),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentStep == 0)
              buildInputCard("Task Name", "Enter Task name", taskNameController),
            if (currentStep == 1)
              buildInputCard("Description", "Enter Task Description", descriptionController, maxLines: 3),
            if (currentStep == 2)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: ListTile(
                  title: const Text(
                    "Deadline",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    selectedDeadline != null 
                        ? "${selectedDeadline!.day}-${selectedDeadline!.month}-${selectedDeadline!.year} ${selectedTime != null ? "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}" : ""}"
                        : "Select Deadline",
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: const Icon(Icons.calendar_today, color: Colors.teal),
                  onTap: () async {
                    await selectDeadline(context); // Select date first
                    // ignore: use_build_context_synchronously
                    await selectTime(context); // Select time after date
                  },
                ),
              ),
            if (currentStep == 3)
              buildDropdownCard("Priority", priorities, selectedPriority, (newValue) {
                setState(() {
                  selectedPriority = newValue!;
                });
              }),
            if (currentStep == 4)
              buildDropdownCard("Category", categories, selectedCategory, (newValue) {
                setState(() {
                  selectedCategory = newValue!;
                });
              }),
            if (currentStep == 5) buildPreview(),

            const SizedBox(height: 20),

            Center(
              child: currentStep < 5
                  ? ElevatedButton(
                      onPressed: () {
                        if (currentStep == 0 && taskNameController.text.isEmpty ||
                            currentStep == 1 && descriptionController.text.isEmpty ||
                            currentStep == 2 && (selectedDeadline == null || selectedTime == null) ||
                            currentStep == 3 && selectedPriority == "Select Priority" ||
                            currentStep == 4 && selectedCategory == "Select Category") {
                          Fluttertoast.showToast(
                            msg: "Please fill in the field",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        } else {
                          nextStep();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 3, 31, 78),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 48,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Next",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        // Show the preview when the Submit button is clicked
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Confirm Task"),
                              content: buildPreviewContent(),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close the preview dialog
                                  },
                                  child: const Text("Edit"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close the preview dialog
                                    submitTask(); // Proceed to submit the task
                                  },
                                  child: const Text("Confirm"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 3, 31, 78),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 48,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
            if (currentStep > 0)
              Center(
                child: TextButton(
                  onPressed: previousStep,
                  child: const Text("Previous"),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildPreview() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Preview",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Task Name: ${taskNameController.text}"),
            Text("Description: ${descriptionController.text}"),
            Text("Deadline: ${selectedDeadline != null ? "${selectedDeadline!.day}-${selectedDeadline!.month}-${selectedDeadline!.year} ${selectedTime != null ? "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}" : ""}" : "Not Set"}"),
            Text("Priority: $selectedPriority"),
            Text("Category: $selectedCategory"),
          ],
        ),
      ),
    );
  }

  Widget buildPreviewContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Task Name: ${taskNameController.text}"),
        Text("Description: ${descriptionController.text}"),
        Text("Deadline: ${selectedDeadline != null ? "${selectedDeadline!.day}-${selectedDeadline!.month}-${selectedDeadline!.year} ${selectedTime != null ? "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}" : ""}" : "Not Set"}"),
        Text("Priority: $selectedPriority"),
        Text("Category: $selectedCategory"),
      ],
    );
  }

  Widget buildInputCard(String title, String hint, TextEditingController controller, {int maxLines = 1}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.teal, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.teal, width: 1.0),
          ),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          labelText: title,
          labelStyle: const TextStyle(color: Colors.teal),
        ),
      ),
    );
  }

  Widget buildDropdownCard(String title, List<String> items, String selectedValue, Function(String?) onChanged) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.teal, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.teal, width: 1.0),
          ),
          labelText: title,
          labelStyle: const TextStyle(color: Colors.teal),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
