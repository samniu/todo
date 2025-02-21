import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../utils/date_formatter.dart';
import '../widgets/note_sheet.dart';

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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _isCompleted = widget.todo.isCompleted;
    _isFavorite = widget.todo.isFavorite;
    _dueDate = widget.todo.dueDate;
    _note = widget.todo.description;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveTodo() {
    final updatedTodo = widget.todo.copyWith(
      title: _titleController.text,
      isCompleted: _isCompleted,
      isFavorite: _isFavorite,
      dueDate: _dueDate,
      description: _note,
    );
    widget.onSave(updatedTodo);
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
                title: const Text(
                  'Today',
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
                title: const Text(
                  'Tomorrow',
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
                title: const Text(
                  'Next Week',
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
                title: const Text(
                  'Pick a date',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _saveTodo();
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
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              _saveTodo();
            },
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
                  onTap: () {
                    setState(() {
                      _isCompleted = !_isCompleted;
                    });
                    _saveTodo();
                  },
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
                    onChanged: (_) => _saveTodo(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.add, color: Colors.white70),
            title: const Text(
              'Add Step',
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
            title: const Text(
              'Remind Me',
              style: TextStyle(color: Colors.white70),
            ),
            onTap: () {
              // TODO: Implement reminder
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.white70),
            title: Text(
              _dueDate == null ? 'Add Due Date' : DateFormatter.formatTaskDate(_dueDate),
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: _dueDate != null ? IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: () {
                setState(() {
                  _dueDate = null;
                });
                _saveTodo();
              },
            ) : null,
            onTap: _showDatePicker,
          ),
          ListTile(
            leading: const Icon(Icons.repeat, color: Colors.white70),
            title: const Text(
              'Repeat',
              style: TextStyle(color: Colors.white70),
            ),
            onTap: () {
              // TODO: Implement repeat
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_file, color: Colors.white70),
            title: const Text(
              'Add File',
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
              title: const Text(
                'Add Note',
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
                  'Created ${DateFormatter.formatCreatedTime(widget.todo.createdAt)}',
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
    );
  }
}