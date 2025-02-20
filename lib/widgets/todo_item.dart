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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Material(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => onEdit(todo),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // 自定义完成状态图标
                GestureDetector(
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
                const SizedBox(width: 12),
                // 任务内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: TextStyle(
                          color: todo.isCompleted ? Colors.white38 : Colors.white,
                          decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                          fontSize: 16,
                        ),
                      ),
                      if (todo.dueDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MM月dd日 HH:mm').format(todo.dueDate!),
                          style: TextStyle(
                            color: todo.isCompleted ? Colors.white24 : Colors.white60,
                            fontSize: 12,
                            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // 收藏按钮
                IconButton(
                  icon: Icon(
                    todo.isFavorite ? Icons.star : Icons.star_border,
                    color: todo.isFavorite ? Colors.amber : Colors.white70,
                    size: 22,
                  ),
                  onPressed: () => onToggleFavorite(todo.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}