import 'package:uuid/uuid.dart';
import 'repeat_type.dart';

class Todo {
  final String id;
  final int? user_id;
  String title;
  String? description;
  bool is_completed;
  bool is_favorite;
  DateTime created_at;
  DateTime? updated_at;
  DateTime? due_date;
  String? list_id;
  int? position;
  final RepeatType? repeat_type;
  String? note;

  Todo({
    String? id,
    this.user_id,
    required this.title,
    this.description,
    this.is_completed = false,
    this.is_favorite = false,
    DateTime? created_at,
    this.updated_at,
    this.due_date,
    this.list_id,
    this.position,
    this.repeat_type,
    this.note,
  }) : id = id ?? const Uuid().v4(),
       created_at = created_at ?? DateTime.now().toUtc();

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'].toString(),
      user_id: json['user_id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String?,
      is_completed: json['is_completed'] as bool? ?? false,
      is_favorite: json['is_favorite'] as bool? ?? false,
      created_at: DateTime.parse(json['created_at']).toLocal(), // 转换为本地时间
      updated_at: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']).toLocal() // 转换为本地时间
          : null,
      due_date: json['due_date'] != null 
          ? DateTime.parse(json['due_date']).toLocal() // 转换为本地时间
          : null,
      list_id: json['list_id'] as String?,
      position: json['position'] as int?,
      repeat_type: json['repeat_type'] != null 
          ? RepeatType.values.firstWhere(
              (e) => e.toString().split('.').last == json['repeat_type'], // 解析字符串为枚举
              orElse: () => RepeatType.none,
            )
          : null,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': user_id,
      'title': title,
      'description': description,
      'is_completed': is_completed,
      'is_favorite': is_favorite,
      'created_at': created_at.toUtc().toIso8601String(), // 确保存储 UTC
      'updated_at': updated_at?.toUtc().toIso8601String(), // 确保存储 UTC
      'due_date': due_date?.toUtc().toIso8601String(), // 确保存储 UTC
      'list_id': list_id,
      'position': position,
      'repeat_type': repeat_type?.toString().split('.').last, // 将枚举转换为字符串
      'note': note,
    };
  }

  Todo copyWith({
    String? title,
    String? description,
    bool? is_completed,
    bool? is_favorite,
    DateTime? due_date,
    String? list_id,
    int? position,
    RepeatType? repeat_type,
    String? note,
    bool? clear_description,
    bool? clear_due_date,
    bool? clear_list_id,
    bool? clear_note,
  }) {
    return Todo(
      id: id,
      user_id: user_id,
      title: title ?? this.title,
      description: clear_description == true ? null : (description ?? this.description),
      is_completed: is_completed ?? this.is_completed,
      is_favorite: is_favorite ?? this.is_favorite,
      created_at: created_at,
      updated_at: DateTime.now().toUtc(),
      due_date: clear_due_date == true ? null : (due_date ?? this.due_date),
      list_id: clear_list_id == true ? null : (list_id ?? this.list_id),
      position: position ?? this.position,
      repeat_type: repeat_type ?? this.repeat_type,
      note: clear_note == true ? null : (note ?? this.note),
    );
  }

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, description: $description, '
           'is_completed: $is_completed, is_favorite: $is_favorite, '
           'created_at: $created_at, updated_at: $updated_at, '
           'due_date: $due_date, list_id: $list_id, position: $position, '
           'repeat_type: $repeat_type, note: $note)';
  }
}