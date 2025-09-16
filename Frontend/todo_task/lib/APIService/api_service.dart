import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Configuration/config.dart';
import '../Model/todo_task_model.dart';
import '../Util/device_helper.dart';

class ApiService {
  Future<List<TodoTask>> fetchTasks() async {
    final deviceId = await DeviceHelper.getDeviceId();
    final response = await http.get(
      Uri.parse("${Config.baseUrl}${Config.getAllTodoTask}?userId=$deviceId"),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => TodoTask.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load tasks");
    }
  }

  Future<TodoTask> addTask(TodoTask task) async {
    final deviceId = await DeviceHelper.getDeviceId();

    final taskWithUserId = {
      "title": task.title,
      "description": task.description,
      "completed": task.completed,
      "userId": deviceId,
    };

    final response = await http.post(
      Uri.parse(Config.baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(taskWithUserId),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return TodoTask.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to add task");
    }
  }

  Future<TodoTask> updateTask(TodoTask task) async {
    final deviceId = await DeviceHelper.getDeviceId();
    final response = await http.put(
      Uri.parse("${Config.baseUrl}/${task.id}?userId=$deviceId"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode == 200) {
      return TodoTask.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to update task: ${response.statusCode}");
    }
  }

  Future<void> deleteTask(int id) async {
    final deviceId = await DeviceHelper.getDeviceId();
    final response = await http.delete(
      Uri.parse("${Config.baseUrl}/$id?userId=$deviceId"),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to delete task");
    }
  }
}
