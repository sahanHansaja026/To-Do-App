import 'package:firebase_database/firebase_database.dart';

class TaskService {
  final DatabaseReference tasksRef = FirebaseDatabase.instance.ref().child('tasks');

  Future<void> updateTask(String taskId, Map<String, dynamic> updatedData) async {
    try {
      await tasksRef.child(taskId).update(updatedData);
    } catch (error) {
      print("Failed to update task: $error");
      throw Exception("Failed to update task");
    }
  }
}
