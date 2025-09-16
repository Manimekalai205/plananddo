import 'package:flutter/material.dart';

import '../Model/todo_task_model.dart';
import '../Util/undo_redo_manager.dart';

enum ActiveField { title, description }

class TaskFormPage extends StatefulWidget {
  final TodoTask? task;
  const TaskFormPage({super.key, this.task});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;

  final _titleManager = UndoRedoManager();
  final _descManager = UndoRedoManager();

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descFocusNode = FocusNode();

  ActiveField _activeField = ActiveField.title;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(
      text: widget.task?.description ?? '',
    );

    // initialize history with initial values
    _titleManager.onChange(_titleController.text);
    _descManager.onChange(_descController.text);

    _titleController.addListener(() {
      _titleManager.onChange(_titleController.text);
      setState(() {}); // refresh icons state
    });

    _descController.addListener(() {
      _descManager.onChange(_descController.text);
      setState(() {}); // refresh icons state
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _titleFocusNode.dispose();
    _descFocusNode.dispose();
    super.dispose();
  }

  void _undoTitle() {
    final value = _titleManager.undo();
    if (value != null) {
      _titleController.value = TextEditingValue(
        text: _titleManager.applyProgrammaticChange(value),
        selection: TextSelection.collapsed(offset: value.length),
      );
      _titleManager.endProgrammaticChange();
    }
  }

  void _redoTitle() {
    final value = _titleManager.redo();
    if (value != null) {
      _titleController.value = TextEditingValue(
        text: _titleManager.applyProgrammaticChange(value),
        selection: TextSelection.collapsed(offset: value.length),
      );
      _titleManager.endProgrammaticChange();
    }
  }

  void _undoDesc() {
    final value = _descManager.undo();
    if (value != null) {
      _descController.value = TextEditingValue(
        text: _descManager.applyProgrammaticChange(value),
        selection: TextSelection.collapsed(offset: value.length),
      );
      _descManager.endProgrammaticChange();
    }
  }

  void _redoDesc() {
    final value = _descManager.redo();
    if (value != null) {
      _descController.value = TextEditingValue(
        text: _descManager.applyProgrammaticChange(value),
        selection: TextSelection.collapsed(offset: value.length),
      );
      _descManager.endProgrammaticChange();
    }
  }

  bool get _canUndoActive =>
      _activeField == ActiveField.title
          ? _titleManager.canUndo
          : _descManager.canUndo;

  bool get _canRedoActive =>
      _activeField == ActiveField.title
          ? _titleManager.canRedo
          : _descManager.canRedo;

  void _undo() {
    if (_activeField == ActiveField.title) {
      _undoTitle();
    } else {
      _undoDesc();
    }
  }

  void _redo() {
    if (_activeField == ActiveField.title) {
      _redoTitle();
    } else {
      _redoDesc();
    }
  }

  void _saveTask() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter title")));
      return;
    }
    if (_descController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter description")));
      return;
    }

    final task = TodoTask(
      id: widget.task?.id,
      title: _titleController.text,
      description: _descController.text,
    );
    Navigator.pop(context, task);
  }

  String _formattedDateTimeWithCount() {
    final now = DateTime.now();
    final formatted =
        "${_weekdayName(now.weekday)}, ${_monthName(now.month)} ${now.day}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    final count = _descController.text.length;
    return "$formatted | $count characters";
  }

  String _weekdayName(int weekday) {
    const weekdays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];
    return weekdays[weekday - 1];
  }

  String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.undo, color: Colors.white),
            onPressed: _canUndoActive ? _undo : null,
            tooltip:
                'Undo (${_activeField == ActiveField.title ? "Title" : "Description"})',
          ),
          IconButton(
            icon: const Icon(Icons.redo, color: Colors.white),
            onPressed: _canRedoActive ? _redo : null,
            tooltip:
                'Redo (${_activeField == ActiveField.title ? "Title" : "Description"})',
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _saveTask,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                focusNode: _titleFocusNode,
                onTap: () => setState(() => _activeField = ActiveField.title),
                decoration: const InputDecoration(
                  hintText: "Title",
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formattedDateTimeWithCount(),
                textAlign: TextAlign.start,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              TextField(
                controller: _descController,
                focusNode: _descFocusNode,
                onTap:
                    () =>
                        setState(() => _activeField = ActiveField.description),
                decoration: const InputDecoration(
                  hintText: "Description",
                  border: InputBorder.none,
                ),
                minLines: 3,
                maxLines: null,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
