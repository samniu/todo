import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../utils/date_formatter.dart';

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

class _QuickAddTaskState extends State<QuickAddTask> 
    with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  DateTime? _dueDate;
  bool _showDatePicker = false;
  
  late final AnimationController _animationController;
  late final Animation<double> _datePickerAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _datePickerAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleQuickDate(DateTime date) {
    setState(() {
      _dueDate = date;
      _showDatePicker = false;
    });
    _animationController.reverse();
  }

  void _showDatePickerSheet() {
    setState(() {
      _showDatePicker = !_showDatePicker;
    });
    if (_showDatePicker) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _closeDatePicker() {
    setState(() {
      _showDatePicker = false;
    });
    _animationController.reverse();
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

  Widget _buildDatePicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
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
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
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
            leading: const Icon(Icons.calendar_view_day, 
                color: Colors.white70),
            title: const Text('Pick a date',
                style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, 
                color: Colors.white70),
            onTap: () async {
              final now = DateTime.now();
              final lastDate = DateTime(now.year + 1, now.month, now.day);
              
              final picked = await showDatePicker(
                context: context,
                initialDate: now,
                firstDate: now,
                lastDate: lastDate,
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
                _closeDatePicker();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaskInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              decoration: InputDecoration(
                hintText: 'Add a Task',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
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
          if (_dueDate != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Chip(
                backgroundColor: Colors.white.withOpacity(0.1),
                label: Text(
                  DateFormatter.formatTaskDate(_dueDate),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                onDeleted: () {
                  setState(() {
                    _dueDate = null;
                  });
                },
                deleteIcon: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white70,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
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
            color: _showDatePicker || _dueDate != null 
                ? Colors.tealAccent 
                : Colors.white70,
            iconSize: 22,
            splashRadius: 22,
            onPressed: _showDatePickerSheet,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showDatePicker)
            SizeTransition(
              sizeFactor: _datePickerAnimation,
              child: _buildDatePicker(),
            ),
          _buildTaskInput(),
          _buildBottomBar(),
        ],
      ),
    );
  }
}