import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../models/repeat_type.dart';
import '../utils/date_formatter.dart';
import '../widgets/note_sheet.dart';
import '../widgets/repeat_sheet.dart';
import 'package:get/get.dart';

class TaskDetailPage extends StatefulWidget {
  final Todo todo;
  final Function(Todo) onSave;
  final Function(String) onDelete;

  const TaskDetailPage({
    super.key,
    required this.todo,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late TextEditingController _titleController;
  late bool _isCompleted;
  late bool _isFavorite;
  late DateTime? _dueDate;
  late String? _note;
  RepeatType? _repeatType;
  bool _hasChanges = false; // 添加标记，跟踪是否有修改

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _titleController = TextEditingController(text: widget.todo.title);
    _isCompleted = widget.todo.is_completed;
    _isFavorite = widget.todo.is_favorite;
    _dueDate = widget.todo.due_date;
    _note = widget.todo.description;
    _repeatType = widget.todo.repeat_type;
    _hasChanges = false;
  }

  bool _checkIfChanged() {
    return _titleController.text != widget.todo.title ||
        _isCompleted != widget.todo.is_completed ||
        _isFavorite != widget.todo.is_favorite ||
        _dueDate != widget.todo.due_date ||
        _note != widget.todo.description ||
        _repeatType != widget.todo.repeat_type;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveTodo() {
    if (!_checkIfChanged()) {
      print("No changes detected, skipping save");
      return;
    }

    print("Todos saved _repeatType: $_repeatType"); 
    print("Todos saved _dueDate: $_dueDate"); 
    final updatedTodo = widget.todo.copyWith(
      title: _titleController.text,
      is_completed: _isCompleted,
      is_favorite: _isFavorite,
      due_date: _dueDate,// 如果 _dueDate 为 null，则取决于 clearDueDate
      description: _note,
      repeat_type: _repeatType,
      clear_due_date: _dueDate == null,   // 如果用户想要清空 dueDate
      clear_description: _note == null,  // 如果用户想要清空 description
    );
    print("Todos saved: $updatedTodo"); // 调试输出
    widget.onSave(updatedTodo);
    _hasChanges = false;
  }
    
  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Due',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      child: const Text(
                        'Done',
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.today, color: Colors.white70),
                title: Text(
                  'today'.tr,
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  DateFormatter.getDayName(DateTime.now()),
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                onTap: () {
                  setState(() {
                    _dueDate = DateTime.now();
                  });
                  _saveTodo();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.white70),
                title: Text(
                  'tomorrow'.tr,
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  DateFormatter.getDayName(
                    DateTime.now().add(const Duration(days: 1)),
                  ),
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                onTap: () {
                  setState(() {
                    _dueDate = DateTime.now().add(const Duration(days: 1));
                  });
                  _saveTodo();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month, color: Colors.white70),
                title: Text(
                  'nextweek'.tr,
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  DateFormatter.getDayName(
                    DateTime.now().add(const Duration(days: 7)),
                  ),
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                onTap: () {
                  setState(() {
                    _dueDate = DateTime.now().add(const Duration(days: 7));
                  });
                  _saveTodo();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_view_day, color: Colors.white70),
                title: Text(
                  'pickadate'.tr,
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white70),
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
                    setState(() {
                      _dueDate = picked;
                    });
                    _saveTodo();
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openNoteEditor() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NoteSheet(
        initialNote: _note,
        onSave: (note) {
          setState(() {
            _note = note;
          });
          _saveTodo();
        },
      ),
    );
  }

  // 添加一个辅助方法来获取重复类型的显示文本
  String _getRepeatText(RepeatType type) {
    switch (type) {
      case RepeatType.daily:
        return 'daily'.tr;
      case RepeatType.weekly:
        return 'weekly'.tr;
      case RepeatType.weekdays:
        return 'weekdays'.tr;
      case RepeatType.monthly:
        return 'monthly'.tr;
      case RepeatType.yearly:
        return 'yearly'.tr;
      default:
        return 'repeat'.tr;
    }
  }

  // 修改所有更新状态的地方，添加 _hasChanges = true
  void _updateState(VoidCallback updateFn) {
    setState(() {
      updateFn();
      _hasChanges = true;
    });
  }

  // 例如，修改 favorite 状态的方法
  void _toggleFavorite() {
    _updateState(() {
      _isFavorite = !_isFavorite;
    });
    _saveTodo();
  }

  // 修改完成状态的方法
  void _toggleComplete() {
    _updateState(() {
      _isCompleted = !_isCompleted;
    });
    _saveTodo();
  }

  // 清除截止日期
  void _clearDueDate() {
    _updateState(() {
      _dueDate = null;
      _repeatType = RepeatType.none;
    });
    _saveTodo();
  }

  // 清除重复设置
  void _clearRepeat() {
    _updateState(() {
      _repeatType = RepeatType.none;
    });
    _saveTodo();
  }

  // 修改重复类型和截止日期
  void _updateRepeatTypeAndDueDate(RepeatType? type) {
    _updateState(() {
      _repeatType = type;
      if (_dueDate == null && type != null) {
        final now = DateTime.now();
        switch (type) {
          case RepeatType.daily:
            _dueDate = DateTime(now.year, now.month, now.day);
            break;
          case RepeatType.weekly:
            _dueDate = DateTime(now.year, now.month, now.day);
            break;
          case RepeatType.weekdays:
            if (now.weekday == DateTime.saturday) {
              _dueDate = now.add(const Duration(days: 2));
            } else if (now.weekday == DateTime.sunday) {
              _dueDate = now.add(const Duration(days: 1));
            } else {
              _dueDate = DateTime(now.year, now.month, now.day);
            }
            break;
          case RepeatType.monthly:
          case RepeatType.yearly:
            _dueDate = DateTime(now.year, now.month, now.day);
            break;
          default:
            break;
        }
      }
    });
    _saveTodo();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          _saveTodo();
        }
        return true;
      },      
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
             if (_hasChanges) {
                _saveTodo();
              }
              Navigator.pop(context);
            },
          ),
          title: const Text('My Day'),
          actions: [
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.star : Icons.star_border,
                color: _isFavorite ? Colors.amber : Colors.white70,
              ),
              onPressed: _toggleFavorite,
            ),
          ],
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _toggleComplete,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isCompleted ? Colors.transparent : Colors.white70,
                          width: 2,
                        ),
                        color: _isCompleted ? Colors.white70 : Colors.transparent,
                      ),
                      child: _isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.black87,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        decoration: _isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        _hasChanges = true;
                        _saveTodo();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.add, color: Colors.white70),
              title: Text(
                'add_step'.tr,
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {
                // TODO: Implement add step
              },
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.wb_sunny_outlined, color: Colors.white70),
              title: const Text(
                'Added to My Day',
                style: TextStyle(color: Colors.white70),
              ),
              trailing: const Icon(Icons.close, color: Colors.white70),
              onTap: () {
                // TODO: Implement remove from My Day
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_none, color: Colors.white70),
              title: Text(
                'remind_me'.tr,
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {
                // TODO: Implement reminder
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.white70),
              title: Text(
                _dueDate == null ? 'add_due_date'.tr : DateFormatter.formatTaskDate(_dueDate),
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: _dueDate != null ? IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: _clearDueDate,
              ) : null,
              onTap: _showDatePicker,
            ),
            ListTile(
              leading: const Icon(Icons.repeat, color: Colors.white70),
              title: _repeatType == null || _repeatType == RepeatType.none
                  ? Text(
                      'repeat'.tr,
                      style: TextStyle(color: Colors.white70),
                    )
                  : Text(
                      _getRepeatText(_repeatType!),
                      style: const TextStyle(color: Colors.blue),
                    ),
              trailing: _repeatType != null && _repeatType != RepeatType.none
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: _clearRepeat,
                    )
                  : null,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => RepeatSheet(
                    initialRepeatType: _repeatType,
                    onSave: _updateRepeatTypeAndDueDate,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file, color: Colors.white70),
              title: Text(
                'add_file'.tr,
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {
                // TODO: Implement add file
              },
            ),
            const Divider(color: Colors.white24),
            if (_note != null) ...[
              InkWell(
                onTap: _openNoteEditor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.edit_note, color: Colors.white70, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Note',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _note!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ] else
              ListTile(
                leading: const Icon(Icons.edit_note, color: Colors.white70),
                title: Text(
                  'add_note'.tr,
                  style: TextStyle(color: Colors.white70),
                ),
                onTap: _openNoteEditor,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created ${DateFormatter.formatCreatedTime(widget.todo.created_at)}',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white70),
                    onPressed: () {
                      widget.onDelete(widget.todo.id);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}