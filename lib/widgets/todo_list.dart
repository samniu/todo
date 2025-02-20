import 'package:flutter/material.dart';
import '../models/todo.dart';
import 'todo_item.dart';

class TodoList extends StatefulWidget {
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
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  bool _showCompleted = true;

  @override
  Widget build(BuildContext context) {
    final incompleteTodos = widget.todos.where((todo) => !todo.isCompleted).toList();
    final completedTodos = widget.todos.where((todo) => todo.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // 未完成的任务
        ...incompleteTodos.map((todo) => TodoItem(
              todo: todo,
              onToggle: widget.onToggle,
              onToggleFavorite: widget.onToggleFavorite,
              onEdit: widget.onEdit,
            )),
        // 已完成的任务头部
        if (completedTodos.isNotEmpty) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              setState(() {
                _showCompleted = !_showCompleted;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Icon(
                    _showCompleted
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '已完成 ${completedTodos.length}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 已完成的任务列表（可折叠）
          if (_showCompleted) 
            ...completedTodos.map((todo) => TodoItem(
                  todo: todo,
                  onToggle: widget.onToggle,
                  onToggleFavorite: widget.onToggleFavorite,
                  onEdit: widget.onEdit,
                )),
        ],
      ],
    );
  }
}