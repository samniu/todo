import 'package:flutter/material.dart';
import '../models/todo.dart';
import 'todo_item.dart';

class TodoList extends StatelessWidget {
  final List<Todo> todos;
  final Function(String) onToggle;
  final Function(String) onToggleFavorite;
  final Function(Todo) onEdit;

  const TodoList({
    super.key,
    required this.todos,
    required this.onToggle,
    required this.onToggleFavorite,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    // 分离已完成和未完成的任务
    final incompleteTodos = todos.where((todo) => !todo.isCompleted).toList();
    final completedTodos = todos.where((todo) => todo.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 未完成的任务
        ...incompleteTodos.map((todo) => TodoItem(
              todo: todo,
              onToggle: onToggle,
              onToggleFavorite: onToggleFavorite,
              onEdit: onEdit,
            )),
        // 如果有已完成的任务，显示分隔符和标题
        if (completedTodos.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              '已完成',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...completedTodos.map((todo) => TodoItem(
                todo: todo,
                onToggle: onToggle,
                onToggleFavorite: onToggleFavorite,
                onEdit: onEdit,
              )),
        ],
      ],
    );
  }
}