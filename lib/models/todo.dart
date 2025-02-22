import 'package:uuid/uuid.dart';
import 'repeat_type.dart';

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
  final RepeatType? repeatType;

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
    this.repeatType,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool,
      isFavorite: json['isFavorite'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueDate:
          json['dueDate'] != null
              ? DateTime.parse(json['dueDate'] as String)
              : null,
      listId: json['listId'] as String?,
      position: json['position'] as int?,
      repeatType: json['repeatType'] != null 
          ? RepeatType.values.firstWhere(
              (e) => e.toString() == json['repeatType'],
              orElse: () => RepeatType.none,
            )
          : null,      
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
      'repeatType': repeatType?.toString(),
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
    RepeatType? repeatType,
    bool? clearDescription,  // 标记是否清空 description
    bool? clearDueDate,      // 标记是否清空 dueDate
    bool? clearListId,       // 其他可能需要清空的字段
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: clearDescription == true ? null : (description ?? this.description),
      isCompleted: isCompleted ?? this.isCompleted,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
      dueDate: clearDueDate == true ? null : (dueDate ?? this.dueDate), // 允许显式清除
      listId: clearListId == true ? null : (listId ?? this.listId),
      position: position ?? this.position,
      repeatType: repeatType ?? this.repeatType,
    );
  }

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, description: $description,isCompleted: $isCompleted, isFavorite: $isFavorite, '
           'createdAt: $createdAt, dueDate: $dueDate, listId: $listId, position: $position, repeatType: $repeatType)';
  }
}
