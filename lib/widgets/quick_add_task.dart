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
      _showDatePicker = !_showDatePicker;
    });
  }

  void _closeDatePicker() {
    if (_showDatePicker) {
      setState(() {
        _showDatePicker = false;
      });
    }
  }

  void _handleSubmit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    widget.onSave(Todo(
      title: title,
      dueDate: _dueDate,
    ));
    
    FocusManager.instance.primaryFocus?.unfocus();
    _titleController.clear();
    setState(() {
      _dueDate = null;
      _showDatePicker = false;
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Choose date',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: _closeDatePicker,
                      ),
                    ],
                  ),
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
                    final now = DateTime.now();
                    final lastDate = DateTime(now.year + 1, now.month, now.day); // 设置为一年后
                    
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: now,
                      lastDate: lastDate, // 使用动态计算的结束日期
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Colors.tealAccent,
                              onPrimary: Colors.black,
                              surface: Colors.black87,
                              onSurface: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    
                    if (picked != null) {
                      _handleQuickDate(picked);
                    } else {
                      setState(() {
                        _showDatePicker = false;
                      });
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
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Add a Task',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) {
                      _handleSubmit();
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
                  icon: const Icon(Icons.notifications_none, color: Colors.white70),
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