class TodoTask {
  int? id;
  String title;
  String description;
  bool completed;
  final String? userId;
  DateTime? createdAt;
  DateTime? modifiedAt;

  TodoTask({
    this.id,
    required this.title,
    required this.description,
    this.completed = false,
    this.userId,
    this.createdAt,
    this.modifiedAt,
  });

  factory TodoTask.fromJson(Map<String, dynamic> json) {
    return TodoTask(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      completed: json['completed'],
      userId: json["userId"],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      modifiedAt:
          json['modifiedAt'] != null
              ? DateTime.parse(json['modifiedAt'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      "userId": userId,
      'createdAt': createdAt?.toIso8601String(),
      'modifiedAt': modifiedAt?.toIso8601String(),
    };
  }
}
