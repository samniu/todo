import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../services/storage_service.dart';
import '../widgets/todo_list.dart';
import '../widgets/quick_add_task.dart';
import '../widgets/task_sheet.dart';

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

  void _showQuickAdd() {
    setState(() {
      _showingQuickAdd = true;
    });
    // FocusScope.of(context).requestFocus(_quickAddFocusNode);
    // 添加一个短暂延迟以确保 TextField 已经构建完成
    Future.delayed(const Duration(milliseconds: 50), () {
      FocusScope.of(context).requestFocus(_quickAddFocusNode);
    });    
  }

  void _hideQuickAdd() {
    if (_showingQuickAdd) {
      setState(() {
        _showingQuickAdd = false;
      });
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _hideQuickAdd,
      child:Scaffold(
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
                  // 快速添加任务
                  if (_showingQuickAdd)
                    QuickAddTask(
                      focusNode: _quickAddFocusNode,
                      onSave: (todo) {
                        _addTodo(todo);
                        _hideQuickAdd();
                        setState(() {
                          _showingQuickAdd = false;
                        });
                      },
                      onCancel: () {
                        _hideQuickAdd();
                        setState(() {
                          _showingQuickAdd = false;
                        });
                      },
                    )
                  else
                    // 添加任务按钮
                    Material(
                      color: Colors.black.withOpacity(0.7),
                      child: InkWell(
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
                              const Text(
                                'Add a Task',
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
      ),
    );
  }
}
