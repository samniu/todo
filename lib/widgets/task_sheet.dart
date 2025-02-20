import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';

class TaskSheet extends StatefulWidget {
  final Todo? initialTodo;
  final Function(Todo) onSave;
  final Function(String)? onDelete;

  const TaskSheet({
    super.key,
    this.initialTodo,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends State<TaskSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late bool _isFavorite;
  late DateTime? _dueDate;
  late TimeOfDay? _dueTime;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    final todo = widget.initialTodo;
    _titleController = TextEditingController(text: todo?.title ?? '');
    _descriptionController = TextEditingController(text: todo?.description ?? '');
    _isFavorite = todo?.isFavorite ?? false;
    
    if (todo?.dueDate != null) {
      _dueDate = todo!.dueDate;
      _dueTime = TimeOfDay(
        hour: todo.dueDate!.hour,
        minute: todo.dueDate!.minute,
      );
    } else {
      _dueDate = null;
      _dueTime = null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  DateTime? get _combinedDateTime {
    if (_dueDate == null) return null;
    if (_dueTime == null) return _dueDate;
    return DateTime(
      _dueDate!.year,
      _dueDate!.month,
      _dueDate!.day,
      _dueTime!.hour,
      _dueTime!.minute,
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
      setState(() {
        _dueDate = picked;
      });
      if (_dueTime == null) {
        _selectTime();
      }
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
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
      setState(() {
        _dueTime = picked;
      });
    }
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除任务'),
        content: const Text('确定要删除这个任务吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 关闭对话框
              Navigator.pop(context); // 关闭编辑表单
              if (widget.onDelete != null && widget.initialTodo != null) {
                widget.onDelete!(widget.initialTodo!.id);
              }
            },
            child: const Text(
              '删除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _showError = true;
      });
      return;
    }

    final todo = (widget.initialTodo ?? Todo(title: '')).copyWith(
      title: title,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      dueDate: _combinedDateTime,
      isFavorite: _isFavorite,
    );

    widget.onSave(todo);
    Navigator.pop(context);
  }

  String _formatDateTime() {
    if (_dueDate == null) return '';
    final date = DateFormat('MM月dd日').format(_dueDate!);
    final time = _dueTime != null ? ' ${_dueTime!.format(context)}' : '';
    return '$date$time';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.initialTodo != null;
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (isEditing)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: _handleDelete,
                ),
              Expanded(
                child: Text(
                  isEditing ? '编辑任务' : '添加任务',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            autofocus: !isEditing,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: '输入任务内容...',
              hintStyle: const TextStyle(color: Colors.white54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white12,
              errorText: _showError ? '请输入任务内容' : null,
              prefixIcon: const Icon(Icons.check_circle_outline, color: Colors.white70),
            ),
            onChanged: (value) {
              if (_showError && value.trim().isNotEmpty) {
                setState(() {
                  _showError = false;
                });
              }
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: '添加备注...',
              hintStyle: const TextStyle(color: Colors.white54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white12,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(Icons.calendar_today, size: 18),
                label: Text(
                  _dueDate == null ? '添加截止日期' : _formatDateTime(),
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.white12,
                onPressed: _selectDate,
              ),
              if (_dueDate != null)
                ActionChip(
                  avatar: const Icon(Icons.close, size: 18),
                  label: const Text('清除日期', style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.white12,
                  onPressed: () {
                    setState(() {
                      _dueDate = null;
                      _dueTime = null;
                    });
                  },
                ),
              ActionChip(
                avatar: Icon(
                  _isFavorite ? Icons.star : Icons.star_border,
                  size: 18,
                  color: _isFavorite ? Colors.amber : null,
                ),
                label: Text(
                  _isFavorite ? '已标记重要' : '标记为重要',
                  style: TextStyle(
                    color: _isFavorite ? Colors.amber : Colors.white,
                  ),
                ),
                backgroundColor: Colors.white12,
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _handleSave,
                child: Text(isEditing ? '保存' : '添加'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}