import 'package:flutter/material.dart';
import '../models/todo.dart';

class QuickAddTask extends StatefulWidget {
  final Function(Todo) onSave;
  final VoidCallback onCancel;
  final FocusNode? focusNode;

  const QuickAddTask({
    super.key,
    required this.onSave,
    required this.onCancel,
    this.focusNode,
  });

  @override
  State<QuickAddTask> createState() => _QuickAddTaskState();
}

class _QuickAddTaskState extends State<QuickAddTask> {
  final _titleController = TextEditingController();
  DateTime? _dueDate;
  bool _showDatePicker = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _handleQuickDate(DateTime date) {
    setState(() {
      _dueDate = date;
      _showDatePicker = false;
    });
  }

  void _showDatePickerSheet() {
    setState(() {
      _showDatePicker = true;
    });
  }

  void _handleSubmit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    widget.onSave(Todo(
      title: title,
      dueDate: _dueDate,
    ));

    _titleController.clear();
    setState(() {
      _dueDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showDatePicker)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.today, color: Colors.white70),
                    title: const Text('Today',
                        style: TextStyle(color: Colors.white)),
                    onTap: () => _handleQuickDate(DateTime.now()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today,
                        color: Colors.white70),
                    title: const Text('Tomorrow',
                        style: TextStyle(color: Colors.white)),
                    onTap: () => _handleQuickDate(
                        DateTime.now().add(const Duration(days: 1))),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_month,
                        color: Colors.white70),
                    title: const Text('Next Week',
                        style: TextStyle(color: Colors.white)),
                    onTap: () => _handleQuickDate(
                        DateTime.now().add(const Duration(days: 7))),
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.calendar_view_day, color: Colors.white70),
                    title: const Text('Pick a date',
                        style: TextStyle(color: Colors.white)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2025),
                      );
                      if (picked != null) {
                        _handleQuickDate(picked);
                      }
                    },
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    focusNode: widget.focusNode,
                    // autofocus: true, 
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Add a Task',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _handleSubmit(),
                    onTapOutside: (_) {
                      widget.onCancel();
                    },                                        
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.home_outlined, color: Colors.white70),
                  onPressed: () {
                    // TODO: Implement home action
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none,
                      color: Colors.white70),
                  onPressed: () {
                    // TODO: Implement reminder
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.white70),
                  onPressed: _showDatePickerSheet,
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white70),
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