import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../services/storage_service.dart';
import '../widgets/todo_list.dart';
import '../widgets/quick_add_task.dart';
import '../widgets/task_sheet.dart';
import '../utils/date_formatter.dart';
import 'task_detail_page.dart';
import 'package:get/get.dart';


class MyDayPage extends StatefulWidget {
  final StorageService storageService;

  const MyDayPage({super.key, required this.storageService});

  @override
  State<MyDayPage> createState() => _MyDayPageState();
}

class _MyDayPageState extends State<MyDayPage> {
  List<Todo> _todos = [];
  bool _isLoading = true;
  final FocusNode _quickAddFocusNode = FocusNode();
  bool _showingQuickAdd = false;
  bool _showingDatePicker = false;
  DateTime? _selectedDate;
  String? _quickAddText;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  void dispose() {
    _quickAddFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTodos() async {
    try {
      final todos = await widget.storageService.loadTodos();
      setState(() {
        _todos = todos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveTodos() async {
    try {
      await widget.storageService.saveTodos(_todos);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存失败，请重试'), backgroundColor: Colors.red),
      );
    }
  }

  void _addTodo(Todo todo) {
    setState(() {
      _todos.add(todo);
      _saveTodos();
    });
  }

  void _editTodo(Todo todo) {
    setState(() {
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = todo;
        _saveTodos();
      }
    });
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((todo) => todo.id == id);
      _saveTodos();
    });
  }

  void _toggleTodo(String id) {
    setState(() {
      final todoIndex = _todos.indexWhere((todo) => todo.id == id);
      if (todoIndex != -1) {
        _todos[todoIndex] = _todos[todoIndex].copyWith(
          isCompleted: !_todos[todoIndex].isCompleted,
        );
        _saveTodos();
      }
    });
  }

  void _toggleFavorite(String id) {
    setState(() {
      final todoIndex = _todos.indexWhere((todo) => todo.id == id);
      if (todoIndex != -1) {
        _todos[todoIndex] = _todos[todoIndex].copyWith(
          isFavorite: !_todos[todoIndex].isFavorite,
        );
        _saveTodos();
      }
    });
  }

  void _showTaskSheet([Todo? todo]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => TaskSheet(
            initialTodo: todo,
            onSave: todo == null ? _addTodo : _editTodo,
            onDelete: todo == null ? null : _deleteTodo,
          ),
    );
  }

  void _onTaskTap(Todo todo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TaskDetailPage(
              todo: todo,
              onSave: _editTodo,
              onDelete: _deleteTodo,
            ),
      ),
    );
  }

  void _showQuickAdd() {
    setState(() {
      _showingQuickAdd = true;
      _showingDatePicker = false;
    });

    Future.delayed(const Duration(milliseconds: 50), () {
      if (!_quickAddFocusNode.hasFocus) {
        FocusScope.of(context).requestFocus(_quickAddFocusNode);
      }
    });
  }

  void _hideQuickAdd() {
    setState(() {
      _showingQuickAdd = false;
      _showingDatePicker = false;
      _selectedDate = null;
    });
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _showDatePickerPage() {
    setState(() {
      _showingDatePicker = true;
      _showingQuickAdd = false;
    });
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _hideDatePickerPage(DateTime? date) {
    setState(() {
      _showingDatePicker = false;
      _showingQuickAdd = true;
      if (date != null) {
        _selectedDate = date;
      }
    });
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!_quickAddFocusNode.hasFocus) {
        FocusScope.of(context).requestFocus(_quickAddFocusNode);
      }
    });
  }

  Widget _buildDatePickerPage() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final nextWeek = now.add(const Duration(days: 7));

    // 使用 SafeArea 或者获取底部安全区域高度
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      color: Colors.black87,
      padding: EdgeInsets.only(bottom: bottomPadding), // 添加底部安全区域padding
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(
                  'due_date'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton(
                  child: Text(
                    'done'.tr,
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                  onPressed: () => _hideDatePickerPage(null),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.white70),
            title: Text('today'.tr, style: TextStyle(color: Colors.white)),
            trailing: Text(
              DateFormatter.getDayName(now),
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
            onTap: () => _hideDatePickerPage(now),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.white70),
            title: Text(
              'tomorrow'.tr,
              style: TextStyle(color: Colors.white),
            ),
            trailing: Text(
              DateFormatter.getDayName(tomorrow),
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
            onTap: () => _hideDatePickerPage(tomorrow),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month, color: Colors.white70),
            title:  Text(
              'nextweek'.tr,
              style: TextStyle(color: Colors.white),
            ),
            trailing: Text(
              DateFormatter.getDayName(nextWeek),
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
            onTap: () => _hideDatePickerPage(nextWeek),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_view_day, color: Colors.white70),
            title:  Text(
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
                _hideDatePickerPage(picked);
              }
            },
          ),
          SizedBox(height: 8), // 可选：添加一些额外的底部间距
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // TODO: Implement navigation
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () {
              // TODO: Implement suggestions
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Implement menu
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://picsum.photos/seed/picsum/600/800',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'My Day',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            DateFormat('EEEE, MMMM d').format(DateTime.now()),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TodoList(
                        todos: _todos,
                        onToggle: _toggleTodo,
                        onToggleFavorite: _toggleFavorite,
                        onTaskTap: (todo) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskDetailPage(
                                todo: todo,
                                onSave: _editTodo,
                                onDelete: _deleteTodo,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (!_showingQuickAdd && !_showingDatePicker)
                      Material(
                        color: Colors.black.withOpacity(0.7),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _showQuickAdd,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white70,
                                  size: 24,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'add_task'.tr,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // 遮罩层
          if (_showingQuickAdd || _showingDatePicker)
            Positioned.fill(
              child: GestureDetector(
                onTap: (){
                  if (_showingQuickAdd) {
                    _hideQuickAdd();
                  }
                  if (_showingDatePicker) {
                    _hideDatePickerPage(null);
                  }                  
                },
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            ),
          // 快速添加任务面板
          if (_showingQuickAdd && !_showingDatePicker)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {}, // 防止点击事件穿透
                child: QuickAddTask(
                  focusNode: _quickAddFocusNode,
                  selectedDate: _selectedDate,
                  initialText: _quickAddText, 
                  onTextChanged: (text) {
                    _quickAddText = text;  // 保存输入的文本
                  },                  
                  onSave: (todo) {
                    _addTodo(todo);
                    _quickAddText = null;
                    _hideQuickAdd();
                  },
                  onCancel: _hideQuickAdd,
                  onDateSelect: _showDatePickerPage,
                ),
              ),
            ),
          // 日期选择面板
          if (_showingDatePicker)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {}, // 防止点击事件穿透
                child: _buildDatePickerPage(),
              ),
            ),
        ],
      ),
    );
  }
}
