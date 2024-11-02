import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addTaskDetails(Map<String, dynamic> taskInfoMap, String taskId) async {
    try {
      await _firestore.collection("tasks").doc(taskId).set(taskInfoMap);
    } catch (e) {
      print(e.toString());
      throw e; // Re-throw the error for further handling if necessary
    }
  }
}
