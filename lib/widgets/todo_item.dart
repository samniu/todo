import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../utils/date_formatter.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final Function(String) onToggle;
  final Function(String) onToggleFavorite;
  final Function(Todo) onTap;  // 更改为 onTap

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onToggleFavorite,
    required this.onTap,  // 更新参数名
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black.withOpacity(0.7),
      child: InkWell(
        onTap: () => onTap(todo),  // 更新调用
        child: ListTile(
          leading: GestureDetector(
            onTap: () => onToggle(todo.id),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: todo.isCompleted ? Colors.transparent : Colors.white70,
                  width: 2,
                ),
                color: todo.isCompleted ? Colors.white70 : Colors.transparent,
              ),
              child: todo.isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.black87,
                    )
                  : null,
            ),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              color: Colors.white,
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              decorationColor: Colors.white54,
            ),
          ),
          subtitle: todo.dueDate != null
              ? Text(
                  DateFormatter.formatTaskDate(todo.dueDate),
                  style: TextStyle(
                    color: Colors.white70,
                    decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.white54,
                  ),
                )
              : null,
          trailing: IconButton(
            icon: Icon(
              todo.isFavorite ? Icons.star : Icons.star_border,
              color: todo.isFavorite ? Colors.amber : Colors.white70,
            ),
            onPressed: () => onToggleFavorite(todo.id),
          ),
        ),
      ),
    );
  }
}