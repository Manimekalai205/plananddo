import 'package:flutter/material.dart';
import 'package:todo_task/Pages/task_form_page.dart';
import 'package:todo_task/Pages/todo_task_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do Task App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const TodoTaskPage(),
        '/task_form': (context) => const TaskFormPage(),
      },
    );
  }
}
