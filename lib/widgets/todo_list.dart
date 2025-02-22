import 'package:flutter/material.dart';
import '../models/todo.dart';
import 'todo_item.dart';
import 'package:get/get.dart';


class TodoList extends StatelessWidget {
  final List<Todo> todos;
  final Function(String) onToggle;
  final Function(String) onToggleFavorite;
  final Function(Todo) onTaskTap;  // 更改为 onTaskTap

  const TodoList({
    super.key,
    required this.todos,
    required this.onToggle,
    required this.onToggleFavorite,
    required this.onTaskTap,  // 更新参数名
  });

  @override
  Widget build(BuildContext context) {
    final incompleteTodos = todos.where((todo) => !todo.isCompleted).toList();
    final completedTodos = todos.where((todo) => todo.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...incompleteTodos.map((todo) => TodoItem(
              todo: todo,
              onToggle: onToggle,
              onToggleFavorite: onToggleFavorite,
              onTap: onTaskTap,  // 更新参数名
            )),
        if (completedTodos.isNotEmpty) ...[
           Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'completed'.tr,
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
                onTap: onTaskTap,  // 更新参数名
              )),
        ],
      ],
    );
  }
}