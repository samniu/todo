// lib/models/todo.dart
import 'package:uuid/uuid.dart';

class Todo {
  final String id;
  String title;
  String? description;
  bool isCompleted;
  bool isFavorite;
  DateTime createdAt;
  DateTime? dueDate;
  String? listId;  // 用于分类任务列表
  int? position;   // 用于任务排序

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

  // 从 JSON 创建 Todo 对象
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

  // 转换为 JSON
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

  // 复制 Todo 对象并修改指定属性
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

// lib/models/todo_list.dart
class TodoList {
  final String id;
  String name;
  String? icon;
  DateTime createdAt;
  
  TodoList({
    String? id,
    required this.name,
    this.icon,
    DateTime? createdAt,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now();

  factory TodoList.fromJson(Map<String, dynamic> json) {
    return TodoList(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  TodoList copyWith({
    String? name,
    String? icon,
  }) {
    return TodoList(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      createdAt: createdAt,
    );
  }
}