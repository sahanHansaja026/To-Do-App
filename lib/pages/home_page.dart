import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskmanagerr/components/my_drawer.dart';
import 'package:taskmanagerr/pages/add_task_page.dart';
import 'package:taskmanagerr/pages/taskdeatail_page.dart';
import 'package:intl/intl.dart';
import 'package:taskmanagerr/services/auth/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService authService = AuthService();
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> filteredTasks = [];
  bool isLoading = true;
  String filter = 'All';

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  void fetchTasks() async {
    final userEmail = authService.getUserEmail();
    // ignore: unnecessary_null_comparison
    if (userEmail == null) return; // Ensure user is logged in

    setState(() => isLoading = true);
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("tasks")
          .where("userEmail", isEqualTo: userEmail)
          .get();

      tasks = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      applyFilter(); // Apply filter after fetching tasks
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching tasks: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void applyFilter() {
    final now = DateTime.now();
    setState(() {
      if (filter == 'All') {
        filteredTasks = tasks;
      } else if (filter == 'Completed') {
        filteredTasks = tasks.where((task) {
          final deadline = _parseDeadline(task['deadline']);
          return deadline != null && deadline.isBefore(now);
        }).toList();
      } else if (filter == 'Pending') {
        filteredTasks = tasks.where((task) {
          final deadline = _parseDeadline(task['deadline']);
          return deadline != null && deadline.isAfter(now);
        }).toList();
      }
    });
  }

  DateTime? _parseDeadline(String? deadlineString) {
    if (deadlineString == null) return null;
    try {
      return DateFormat("yyyy-MM-dd'T'HH:mm:ss.sss HH:mm").parse(deadlineString);
    } catch (e) {
      // ignore: avoid_print
      print("Error parsing deadline: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Tasks",
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 2, 56, 255),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchTasks,
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? const Center(child: Text("No tasks available"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Search tasks...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildFilterButton("All Tasks", "All"),
                          _buildFilterButton("Completed", "Completed"),
                          _buildFilterButton("Pending", "Pending"),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];
                            return TaskCard(task: task);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const StudentTaskManager(),
            ),
          );
        },
        // ignore: sort_child_properties_last
        child: const Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 15, 78, 188),
      ),
    );
  }

  Widget _buildFilterButton(String label, String filterValue) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          filter = filterValue;
          applyFilter();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            filter == filterValue ? Colors.blueAccent : Colors.grey[300],
        foregroundColor:
            filter == filterValue ? Colors.white : Colors.black,
      ),
      child: Text(label),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Map<String, dynamic> task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    String deadlineDate = "";
    String deadlineTime = "";

    if (task['deadline'] != null) {
      List<String> deadlineParts = task['deadline'].split(" ");
      deadlineDate = deadlineParts[0].split("T")[0];
      deadlineTime = deadlineParts[1];
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TaskDetails(task: task),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: Theme.of(context).colorScheme.primary,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task['taskName'],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Date: $deadlineDate",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              Text(
                "Time: $deadlineTime",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
