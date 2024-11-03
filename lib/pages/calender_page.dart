import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:taskmanagerr/services/auth/auth_service.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final AuthService authService = AuthService();
  late final String userEmail;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _tasksByDate = {};

  @override
  void initState() {
    super.initState();
    userEmail = authService.getUserEmail(); // Fetch the user's email
    _fetchTasks();
  }

  void _fetchTasks() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('userEmail', isEqualTo: userEmail) // Filter tasks by user email
        .get();

    final tasks = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    Map<DateTime, List<Map<String, dynamic>>> tasksByDate = {};

    for (var task in tasks) {
      DateTime? taskDate = _parseDeadline(task['deadline']);
      if (taskDate != null) {
        final dateOnly = DateTime(taskDate.year, taskDate.month, taskDate.day);
        if (tasksByDate[dateOnly] == null) {
          tasksByDate[dateOnly] = [];
        }
        tasksByDate[dateOnly]!.add(task);
      }
    }

    setState(() {
      _tasksByDate = tasksByDate;
    });
  }

  DateTime? _parseDeadline(String? deadlineString) {
    if (deadlineString == null) return null;
    try {
      return DateFormat("yyyy-MM-dd'T'HH:mm:ss.sss HH:mm").parse(deadlineString);
    } catch (e) {
      print("Error parsing deadline: $e");
      return null;
    }
  }

  List<Map<String, dynamic>> _getTasksForDay(DateTime day) {
    return _tasksByDate[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar"),
        backgroundColor: const Color.fromARGB(255, 2, 56, 255),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() => _calendarFormat = format);
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getTasksForDay,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepOrange,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _selectedDay == null
                ? const Center(child: Text("Select a day to view tasks"))
                : ListView(
                    children: _getTasksForDay(_selectedDay!).map((task) {
                      return ListTile(
                        title: Text(task['taskName'] ?? 'No Name'),
                        subtitle: Text(
                          'Deadline: ${task['deadline'] ?? 'No Deadline'}',
                        ),
                        onTap: () {
                          // Navigate to task details page if needed
                        },
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
