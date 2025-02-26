import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../models/todo.dart';
import '../services/storage_service.dart';
import '../widgets/todo_list.dart';
import '../widgets/quick_add_task.dart';
import '../widgets/task_sheet.dart';
import '../utils/date_formatter.dart';
import '../controllers/quick_add_controller.dart';
import '../controllers/todo_controller.dart';
import '../controllers/auth_controller.dart';
import 'task_detail_page.dart';

class MyDayPage extends StatefulWidget {
  final StorageService storageService;

  const MyDayPage({super.key, required this.storageService});

  @override
  State<MyDayPage> createState() => _MyDayPageState();
}

class _MyDayPageState extends State<MyDayPage> {
  final _quickAddController = Get.find<QuickAddController>();
  final _todoController = Get.find<TodoController>();
  final _authController = Get.find<AuthController>();

  final FocusNode _quickAddFocusNode = FocusNode();
  bool _showingQuickAdd = false;
  bool _showingDatePicker = false;

  @override
  void initState() {
    super.initState();

    // 首先加载任务列表
    _todoController.loadTodos();

  // 使用 Future.microtask 来确保在正确的时机初始化 WebSocket
    Future.microtask(() async {
      if (_authController.isLoggedIn) {
        print('MyDayPage: Initializing WebSocket connection');
        try {
          await _authController.connectWebSocket();
        } catch (e) {
          print('MyDayPage: WebSocket connection error: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _quickAddFocusNode.dispose();
    super.dispose();
  }

  void _showTaskSheet([Todo? todo]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => TaskSheet(
            initialTodo: todo,
            onSave:
                todo == null
                    ? _todoController.addTodo
                    : _todoController.updateTodo,
            onDelete: todo == null ? null : _todoController.deleteTodo,
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
    if (date != null) {
      _quickAddController.setSelectedDate(date);
    }

    setState(() {
      _showingDatePicker = false;
      _showingQuickAdd = true;
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

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      color: Colors.black87,
      padding: EdgeInsets.only(bottom: bottomPadding),
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
            title: Text('tomorrow'.tr, style: TextStyle(color: Colors.white)),
            trailing: Text(
              DateFormatter.getDayName(tomorrow),
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
            onTap: () => _hideDatePickerPage(tomorrow),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month, color: Colors.white70),
            title: Text('nextweek'.tr, style: TextStyle(color: Colors.white)),
            trailing: Text(
              DateFormatter.getDayName(nextWeek),
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
            onTap: () => _hideDatePickerPage(nextWeek),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_view_day, color: Colors.white70),
            title: Text('pickadate'.tr, style: TextStyle(color: Colors.white)),
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
          SizedBox(height: 8),
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
          icon: const Icon(Icons.menu),
          onPressed: () {
            // TODO: Implement menu
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _todoController.loadTodos(),
          ),
          Obx(
            () => IconButton(
              icon: Icon(
                _authController.isLoggedIn ? Icons.cloud_done : Icons.cloud_off,
                color: _authController.isLoggedIn ? Colors.green : Colors.grey,
              ),
              onPressed: () {
                if (!_authController.isLoggedIn) {
                  Get.toNamed('/login');
                }
              },
            ),
          ),
          // 添加状态按钮
          Obx(
            () => IconButton(
              icon: Icon(
                _todoController.hasUnsyncedTasks() ? Icons.sync_problem : Icons.sync,
                color: _todoController.hasUnsyncedTasks() ? Colors.orange : Colors.white,
              ),
              onPressed: () async {
                if (_authController.isLoggedIn) {
                  await _todoController.syncTodos();
                } else {
                  Get.toNamed('/login');
                }
              },
            ),
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
                      child: Obx(() {
                        if (_todoController.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return TodoList(
                          todos: _todoController.sortedTodos,
                          onToggle: _todoController.toggleTodo,
                          onToggleFavorite:
                              (id) => _todoController.toggleFavorite(id),
                          onTaskTap: (todo) {
                            Get.to(
                              () => TaskDetailPage(
                                todo: todo,
                                onSave: _todoController.updateTodo,
                                onDelete: _todoController.deleteTodo,
                              ),
                            );                            
                          },
                        );
                      }),
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
                                Obx(() {
                                  final savedTitle = _quickAddController.title;
                                  return GestureDetector(
                                    onTap: _showQuickAdd, // 确保点击事件可以触发
                                    child: Text(
                                      savedTitle.isNotEmpty
                                          ? savedTitle
                                          : 'add_task'.tr,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),                                  
                                  );
                                }),
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
          if (_showingQuickAdd || _showingDatePicker)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
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
          if (_showingQuickAdd && !_showingDatePicker)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: QuickAddTask(
                focusNode: _quickAddFocusNode,
                onSave: (todo) {
                  _todoController.addTodo(todo);
                  _quickAddController.clearAll();
                  _hideQuickAdd();
                },
                onCancel: _hideQuickAdd,
                onDateSelect: _showDatePickerPage,
              ),
            ),
          if (_showingDatePicker)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildDatePickerPage(),
            ),
        ],
      ),
    );
  }
}
