import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/todo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const MyDayPage(),
    );
  }
}

class MyDayPage extends StatefulWidget {
  const MyDayPage({super.key});

  @override
  State<MyDayPage> createState() => _MyDayPageState();
}

class _MyDayPageState extends State<MyDayPage> {
  // 示例数据
  final List<Todo> todos = [
    Todo(
      title: '在 GitHub 创建首个商业化仓库',
      createdAt: DateTime.now(),
    ),
    Todo(
      title: '听力15分钟',
      isCompleted: true,
      createdAt: DateTime.now(),
    ),
    Todo(
      title: '听写句子10个',
      isCompleted: true,
      createdAt: DateTime.now(),
    ),
    Todo(
      title: '背单词10个',
      isCompleted: true,
      createdAt: DateTime.now(),
    ),
  ];

  void _toggleTodo(String id) {
    setState(() {
      final todoIndex = todos.indexWhere((todo) => todo.id == id);
      if (todoIndex != -1) {
        todos[todoIndex] = todos[todoIndex].copyWith(
          isCompleted: !todos[todoIndex].isCompleted,
        );
      }
    });
  }

  void _toggleFavorite(String id) {
    setState(() {
      final todoIndex = todos.indexWhere((todo) => todo.id == id);
      if (todoIndex != -1) {
        todos[todoIndex] = todos[todoIndex].copyWith(
          isFavorite: !todos[todoIndex].isFavorite,
        );
      }
    });
  }

  void _addTodo(String title) {
    setState(() {
      todos.add(Todo(
        title: title,
        createdAt: DateTime.now(),
      ));
    });
  }

  void _showAddTodoSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTodoSheet(onAdd: _addTodo),
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
                  child: TodoList(
                    todos: todos,
                    onToggle: _toggleTodo,
                    onToggleFavorite: _toggleFavorite,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoSheet,
        child: const Icon(Icons.add),
      ),

    );
  }
}

class AddTodoSheet extends StatefulWidget {
  final Function(String) onAdd;

  const AddTodoSheet({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<AddTodoSheet> {
  final _textController = TextEditingController();
  bool _showError = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final title = _textController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _showError = true;
      });
      return;
    }

    widget.onAdd(title);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
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
              const Expanded(
                child: Text(
                  '添加任务',
                  style: TextStyle(
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
            controller: _textController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: '输入新任务...',
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
            onSubmitted: (_) => _handleSubmit(),
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
                onPressed: _handleSubmit,
                child: const Text('添加'),
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

  const TodoList({
    super.key,
    required this.todos,
    required this.onToggle,
    required this.onToggleFavorite,
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
        ...incompleteTodos.map((todo) => TodoItem(
              todo: todo,
              onToggle: onToggle,
              onToggleFavorite: onToggleFavorite,
            )),
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
          ...completedTodos.map((todo) => TodoItem(
                todo: todo,
                onToggle: onToggle,
                onToggleFavorite: onToggleFavorite,
              )),
        ],
      ],
    );
  }
}

class TodoItem extends StatelessWidget {
  final Todo todo;
  final Function(String) onToggle;
  final Function(String) onToggleFavorite;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black.withOpacity(0.7),
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
          'Today',
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
    );
  }
}