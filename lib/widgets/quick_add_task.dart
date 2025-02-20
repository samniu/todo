import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../utils/date_formatter.dart';

class QuickAddTask extends StatefulWidget {
  final Function(Todo) onSave;
  final VoidCallback onCancel;
  final VoidCallback onDateSelect;
  final FocusNode? focusNode;
  final DateTime? selectedDate;

  const QuickAddTask({
    super.key,
    required this.onSave,
    required this.onCancel,
    required this.onDateSelect,
    this.focusNode,
    this.selectedDate,
  });

  @override
  State<QuickAddTask> createState() => _QuickAddTaskState();
}

class _QuickAddTaskState extends State<QuickAddTask> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    widget.onSave(Todo(
      title: title,
      dueDate: widget.selectedDate,
    ));
    
    _titleController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white54,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    focusNode: widget.focusNode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Add a Task',
                      hintStyle: TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) {
                      _handleSubmit();
                      widget.onCancel();
                    },
                  ),
                ),
                if (widget.selectedDate != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Chip(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      label: Text(
                        DateFormatter.formatTaskDate(widget.selectedDate),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      deleteIcon: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white70,
                      ),
                      onDeleted: () {
                        widget.onCancel();
                      },
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.home_outlined),
                  color: Colors.white70,
                  iconSize: 22,
                  splashRadius: 22,
                  onPressed: () {
                    // TODO: Implement home action
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  color: Colors.white70,
                  iconSize: 22,
                  splashRadius: 22,
                  onPressed: () {
                    // TODO: Implement reminder
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  color: widget.selectedDate != null 
                      ? Colors.tealAccent 
                      : Colors.white70,
                  iconSize: 22,
                  splashRadius: 22,
                  onPressed: widget.onDateSelect,
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  color: Colors.white70,
                  iconSize: 22,
                  splashRadius: 22,
                  onPressed: () {
                    // TODO: Implement copy action
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}