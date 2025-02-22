import 'package:flutter/material.dart';
import '../models/todo.dart';
import 'todo_item.dart';
import 'package:get/get.dart';

class TodoList extends StatefulWidget {
  final List<Todo> todos;
  final Function(String) onToggle;
  final Function(String) onToggleFavorite;
  final Function(Todo) onTaskTap;

  const TodoList({
    super.key,
    required this.todos,
    required this.onToggle,
    required this.onToggleFavorite,
    required this.onTaskTap,
  });

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  bool _isCompletedExpanded = false;

  @override
  Widget build(BuildContext context) {
    final incompleteTodos = widget.todos.where((todo) => !todo.isCompleted).toList();
    final completedTodos = widget.todos.where((todo) => todo.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...incompleteTodos.map((todo) => TodoItem(
              todo: todo,
              onToggle: widget.onToggle,
              onToggleFavorite: widget.onToggleFavorite,
              onTap: widget.onTaskTap,
            )),
        if (completedTodos.isNotEmpty) ...[
          InkWell(
            onTap: () {
              setState(() {
                _isCompletedExpanded = !_isCompletedExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                children: [
                  Icon(
                    _isCompletedExpanded 
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'completed'.tr + ' (${completedTodos.length})',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isCompletedExpanded)
            ...completedTodos.map((todo) => TodoItem(
                  todo: todo,
                  onToggle: widget.onToggle,
                  onToggleFavorite: widget.onToggleFavorite,
                  onTap: widget.onTaskTap,
                )),
        ],
      ],
    );
  }
}