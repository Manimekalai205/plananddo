import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../APIService/api_service.dart';
import '../Model/todo_task_model.dart';
import '../Util/device_helper.dart';
import 'task_form_page.dart';

class TodoTaskPage extends StatefulWidget {
  const TodoTaskPage({super.key});

  @override
  State<TodoTaskPage> createState() => _TodoTaskPageState();
}

class _TodoTaskPageState extends State<TodoTaskPage> {
  final ApiService _apiService = ApiService();
  Future<List<TodoTask>>? _tasks;
  late String _deviceId;

  @override
  void initState() {
    super.initState();
    _initDeviceId();
  }

  void _initDeviceId() async {
    _deviceId = await DeviceHelper.getDeviceId();
    _loadTasks();
  }

  void _loadTasks() {
    _tasks = _apiService.fetchTasks();
    setState(() {});
  }

  Future<void> _addTask() async {
    final task = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TaskFormPage()),
    );
    if (task != null) {
      final newTask = TodoTask(
        title: task.title,
        description: task.description,
        userId: _deviceId,
      );
      await _apiService.addTask(newTask);
      _loadTasks();
    }
  }

  Future<void> _editTask(TodoTask task) async {
    final updatedTask = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskFormPage(task: task)),
    );
    if (updatedTask != null) {
      final taskWithUserId = TodoTask(
        id: updatedTask.id,
        title: updatedTask.title,
        description: updatedTask.description,
        userId: _deviceId,
      );
      await _apiService.updateTask(taskWithUserId);
      _loadTasks();
    }
  }

  Future<void> _deleteTask(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Center(
              child: Text(
                "Confirm Delete",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            content: const Text(
              "Are you sure you want to delete?",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: () => Navigator.pop(context, false),
                child: const Text("No", style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Yes", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await _apiService.deleteTask(id);
      _loadTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6D5DF6), Color(0xFF46A0E3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        title: const Text(
          "Plan & Do 📝",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body:
          _tasks == null
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<List<TodoTask>>(
                future: _tasks,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No tasks found"));
                  }

                  final tasks = snapshot.data!;
                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () => _editTask(task),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _deleteTask(task.id!),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                task.description,
                                style: const TextStyle(fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              if (task.createdAt != null)
                                Text(
                                  DateFormat(
                                    "MMMM dd, yyyy",
                                  ).format(task.createdAt!),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        backgroundColor: const Color(0xFF6D5DF6),
        child: const Icon(Icons.add),
      ),
    );
  }
}
