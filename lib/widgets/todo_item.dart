import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final Function(String) onToggle;
  final Function(String) onToggleFavorite;
  final Function(Todo) onEdit;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onToggleFavorite,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black.withOpacity(0.7),
      child: InkWell(
        onTap: () => onEdit(todo),
        child: ListTile(
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (value) => onToggle(todo.id),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              color: Colors.white,
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              decorationColor: Colors.white54,
            ),
          ),
          subtitle: Text(
            todo.dueDate != null
                ? DateFormat('MM月dd日 HH:mm').format(todo.dueDate!)
                : 'Today',
            style: TextStyle(
              color: Colors.white70,
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              decorationColor: Colors.white54,
            ),
          ),
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