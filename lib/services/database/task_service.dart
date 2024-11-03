import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to add task details
  Future<void> addTaskDetails(Map<String, dynamic> taskInfoMap, String id) async {
    try {
      await _firestore.collection("Tasks").doc(id).set(taskInfoMap);
      Fluttertoast.showToast(
        msg: "Task added successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to add task: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  // Function to get task details as a stream of snapshots
  Stream<QuerySnapshot> getTaskDetails() {
    return _firestore.collection("Tasks").snapshots();
  }
}

class TaskList extends StatelessWidget {
  final DatabaseMethods databaseMethods = DatabaseMethods();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task List"),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: databaseMethods.getTaskDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Error fetching data"),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No tasks available"),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var task = snapshot.data!.docs[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
                child: ListTile(
                  title: Text(
                    "Task Title: ${task['Title']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Deadline: ${task['Deadline']}"),
                      Text("Priority: ${task['Priority']}"),
                      Text("Description: ${task['Description']}"),
                      Text("Category: ${task['Category']}"),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
