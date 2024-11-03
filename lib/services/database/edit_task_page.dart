import 'package:cloud_firestore/cloud_firestore.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> updateTask(String taskId, Map<String, dynamic> updatedTask) async {
    try {
      await _db.collection('tasks').doc(taskId).update(updatedTask);
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }
}
