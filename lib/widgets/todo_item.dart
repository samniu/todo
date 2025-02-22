import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../models/repeat_type.dart';
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

  // 获取状态文本和图标
  Widget _buildStatusRow() {
    final List<Widget> items = [];
    
    // 添加 Tasks 文本
    items.add(
      const Text(
        'Tasks',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
      ),
    );
      
    // 只有在有其他内容时才添加点号
    if (todo.dueDate != null || (todo.repeatType != null && todo.repeatType != RepeatType.none) || (todo.description != null && todo.description!.isNotEmpty)) {
      items.add(const Text(
        ' • ',
        style: TextStyle(color: Colors.white70, fontSize: 12),
      ));
    }

    // 添加截止日期
    if (todo.dueDate != null) {
      items.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today,
            color: Colors.white70,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            DateFormatter.formatTaskDate(todo.dueDate),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ));
    }

    // 添加重复图标
    if (todo.repeatType != null && todo.repeatType != RepeatType.none) {
      if (items.isNotEmpty) {
        items.add(const SizedBox(width: 8));
      }
      items.add(const Icon(
        Icons.repeat,
        color: Colors.white70,
        size: 12,
      ));
    }

    // 添加备注图标
    if (todo.description != null && todo.description!.isNotEmpty) {
      if (items.isNotEmpty) {
        items.add(const SizedBox(width: 8));
      }
      items.add(const Icon(
        Icons.note,
        color: Colors.white70,
        size: 12,
      ));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: items,
    );
  }

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
          subtitle: _buildStatusRow(),
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