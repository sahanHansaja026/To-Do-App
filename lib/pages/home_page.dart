import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskmanagerr/components/my_drawer.dart';
import 'package:taskmanagerr/pages/add_task_page.dart';
import 'package:taskmanagerr/pages/taskdeatail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  void fetchTasks() async {
    setState(() => isLoading = true);
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("tasks").get();
    tasks = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    setState(() => isLoading = false);
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
      drawer: const MyDrawer(), // Add the drawer here
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? const Center(child: Text("No tasks available"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Search Bar
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Search tasks...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .secondary, // Fixed this line
                        ),
                      ),

                      const SizedBox(height: 16),
                      // Task Filter Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Filter logic here
                            },
                            child: const Text("All Tasks"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Filter logic here
                            },
                            child: const Text("Completed"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Filter logic here
                            },
                            child: const Text("Pending"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Task List
                      Expanded(
                        child: ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
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
              builder: (context) =>
                  const StudentTaskManager(), // Navigate to AddTask page
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 15, 78, 188),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Map<String, dynamic> task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
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
                  color: Theme.of(context)
                      .colorScheme
                      .inversePrimary, // Access theme color here
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Deadline: ${task['deadline'] != null ? "${task['deadline'].split("T")[0]} ${task['deadline'].split("T")[1].split(".")[0]}" : "Not set"}",
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .inversePrimary, // Dynamically get color from theme
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
