import 'package:uuid/uuid.dart';

class Todo {
  final String id;
  String title;
  String? description;
  bool isCompleted;
  bool isFavorite;
  DateTime createdAt;
  DateTime? dueDate;
  String? listId;
  int? position;

  Todo({
    String? id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.isFavorite = false,
    DateTime? createdAt,
    this.dueDate,
    this.listId,
    this.position,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now();

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool,
      isFavorite: json['isFavorite'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueDate: json['dueDate'] != null 
        ? DateTime.parse(json['dueDate'] as String)
        : null,
      listId: json['listId'] as String?,
      position: json['position'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'listId': listId,
      'position': position,
    };
  }

  Todo copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    bool? isFavorite,
    DateTime? dueDate,
    String? listId,
    int? position,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      listId: listId ?? this.listId,
      position: position ?? this.position,
    );
  }
}