import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/todo.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await StorageService.init();
  runApp(MyApp(storageService: storageService));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;

  const MyApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Todo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: MyDayPage(storageService: storageService),
    );
  }
}

class MyDayPage extends StatefulWidget {
  final StorageService storageService;

  const MyDayPage({super.key, required this.storageService});

  @override
  State<MyDayPage> createState() => _MyDayPageState();
}

class _MyDayPageState extends State<MyDayPage> {
  List<Todo> _todos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    try {
      final todos = await widget.storageService.loadTodos();
      setState(() {
        _todos = todos;
        _isLoading = false;
      });
    } catch (e) {
      // TODO: 添加错误处理
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveTodos() async {
    try {
      await widget.storageService.saveTodos(_todos);
    } catch (e) {
      // TODO: 添加错误处理
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存失败，请重试'), backgroundColor: Colors.red),
      );
    }
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

  void _editTodo(Todo todo) {
    setState(() {
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = todo;
        _saveTodos();
      }
    });
  }

void _addTodo(Todo todo) {
  setState(() {
    _todos.add(todo);
    _saveTodos();
  });
}

void _showTaskSheet([Todo? todo]) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TaskSheet(
      initialTodo: todo,
      onSave: todo == null ? _addTodo : _editTodo,
      onDelete: todo != null ? _deleteTodo : null, 
    ),
  );
}

void _deleteTodo(String id) {
  setState(() {
    _todos.removeWhere((todo) => todo.id == id);
    _saveTodos();
  });
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://picsum.photos/seed/picsum/600/800'),
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
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : TodoList(
                            todos: _todos,
                            onToggle: _toggleTodo,
                            onToggleFavorite: _toggleFavorite,
                            onEdit: _showTaskSheet, 
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTaskSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// 重命名并改进原来的 AddTodoSheet
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
    // 初始化状态
    final todo = widget.initialTodo;
    _titleController = TextEditingController(text: todo?.title ?? '');
    _descriptionController = TextEditingController(
      text: todo?.description ?? '',
    );
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

  void _handleDelete() {
    // 如果没有删除回调或没有初始任务，直接返回
    if (widget.onDelete == null || widget.initialTodo == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          '删除任务',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '确定要删除这个任务吗？',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 关闭对话框
              Navigator.pop(context); // 关闭编辑表单
              widget.onDelete!(widget.initialTodo!.id);// 调用删除方法(使用非空断言，因为我们已经检查过了)
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

  void _clearDueDate() {
    setState(() {
      _dueDate = null;
      _dueTime = null;
    });
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
      description:
          _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
      dueDate: _combinedDateTime,
      isFavorite: _isFavorite,
    );

    widget.onSave(todo);
    Navigator.pop(context);
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
      // 如果选择了日期但还没有时间，显示时间选择器
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
              if (isEditing && widget.onDelete != null) // 添加条件检查
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
              prefixIcon: const Icon(
                Icons.check_circle_outline,
                color: Colors.white70,
              ),
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
                  label: const Text(
                    '清除日期',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.white12,
                  onPressed: _clearDueDate,
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

class TodoList extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // 分离已完成和未完成的任务
    final incompleteTodos = todos.where((todo) => !todo.isCompleted).toList();
    final completedTodos = todos.where((todo) => todo.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 未完成的任务
        ...incompleteTodos.map(
          (todo) => TodoItem(
            todo: todo,
            onToggle: onToggle,
            onToggleFavorite: onToggleFavorite,
            onEdit: onEdit, 
          ),
        ),
        // 如果有已完成的任务，显示分隔符和标题
        if (completedTodos.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              '已完成',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...completedTodos.map(
            (todo) => TodoItem(
              todo: todo,
              onToggle: onToggle,
              onToggleFavorite: onToggleFavorite,
              onEdit: onEdit, 
            ),
          ),
        ],
      ],
    );
  }
}

class TodoItem extends StatelessWidget {
  final Todo todo;
  final Function(String) onToggle;
  final Function(String) onToggleFavorite;
  final Function(Todo) onEdit;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onToggleFavorite,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black.withOpacity(0.7),
      child: InkWell(  // 添加 InkWell 以支持点击效果
        onTap: () => onEdit(todo),  // 点击整个卡片时进入编辑
        child: ListTile(
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (value) => onToggle(todo.id),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              color: Colors.white,
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              decorationColor: Colors.white54,
            ),
          ),
          subtitle: Text(
            todo.dueDate != null 
                ? DateFormat('MM月dd日 HH:mm').format(todo.dueDate!)
                : 'Today',
            style: TextStyle(
              color: Colors.white70,
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              decorationColor: Colors.white54,
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              todo.isFavorite ? Icons.star : Icons.star_border,
              color: todo.isFavorite ? Colors.amber : Colors.white70,
            ),
            onPressed: () => onToggleFavorite(todo.id),
          ),
        ),
      ),
    );
  }
}
