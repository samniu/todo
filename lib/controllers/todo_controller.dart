import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../models/todo.dart';
import '../services/storage_service.dart';
import '../services/websocket_service.dart';
import '../controllers/auth_controller.dart';
import '../config/api_config.dart';

class TodoController extends GetxController {
  final storageService = Get.find<StorageService>();
  final authController = Get.find<AuthController>();
  final webSocketService = Get.find<WebSocketService>();

  // 使用 RxList 替代普通的 List
  final todos = RxList<Todo>();
  final completedTodos = RxList<Todo>();
  final isLoading = false.obs;

  // 获取器保持排序
  List<Todo> get sortedTodos {
    // final sortedList = todos.toList();
    final sortedList = [...todos, ...completedTodos];
    print('todos: $todos');
    sortedList.sort((a, b) {
      final aDate = a.created_at;
      final bDate = b.created_at;
      if (aDate == null || bDate == null) return 0;
      return bDate.compareTo(aDate); // 降序排列
    });
    return sortedList;
  }

  List<Todo> get sortedCompletedTodos {
    final sortedList = completedTodos.toList();
    sortedList.sort((a, b) {
      final aDate = a.updated_at;
      final bDate = b.updated_at;
      if (aDate == null || bDate == null) return 0;
      return bDate.compareTo(aDate); // 降序排列
    });
    return sortedList;
  }

  @override
  void onInit() {
    super.onInit();
    // 只在第一次连接成功时加载数据
    once(webSocketService.isConnected, (bool connected) {
      if (connected) {
        loadTodos();
      }
    });
  }

  // 加载数据
  Future<void> loadTodos() async {
    try {
      isLoading.value = true;
      if (authController.isLoggedIn) {
        await _loadFromServer();
      } else {
        await _loadFromLocal();
      }
    } catch (e) {
      print('Error loading todos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 处理 WebSocket 消息
  void handleWebSocketMessage(String type, dynamic data) {
    print('TodoController: Handling WebSocket message of type: $type');
    print('TodoController: Message data: $data');

    if (type == 'auth_success') {
      print('TodoController: WebSocket authentication successful');
      return;
    }

    switch (type) {
      case 'todo_created':
      case 'todo_updated':
      case 'todo_toggled':
        final todo = Todo.fromJson(data);
        _handleTodoUpdated(todo);
        break;

      case 'todo_deleted':
        final todo = Todo.fromJson(data);
        _handleTodoDeleted(todo.id.toString());
        break;
    }
  }

  void _handleTodoUpdated(Todo todo) {
    print('TodoController: Handling todo updated: $todo');
    todos.removeWhere((t) => t.id == todo.id);
    completedTodos.removeWhere((t) => t.id == todo.id);

    if (todo.is_completed) {
      completedTodos.add(todo);
    } else {
      todos.add(todo);
    }
    _saveToLocal();
  }

  void _handleTodoDeleted(String id) {
    print('TodoController: Handling todo deleted: $id');
    todos.removeWhere((todo) => todo.id.toString() == id);
    completedTodos.removeWhere((todo) => todo.id.toString() == id);
    _saveToLocal();
  }

  Future<void> _loadFromServer() async {
    try {
      final response = await GetConnect().get(
        ApiConfig.getTodos(),
        headers: {'Authorization': 'Bearer ${authController.token}'},
      );

      if (response.hasError) {
        throw 'Failed to load todos from server';
      }

      final data = response.body['data'] as List<dynamic>;
      final loadedTodos = data.map((json) => Todo.fromJson(json)).toList();

      todos.assignAll(loadedTodos.where((todo) => !todo.is_completed).toList());
      completedTodos.assignAll(
        loadedTodos.where((todo) => todo.is_completed).toList(),
      );

      await _saveToLocal();
    } catch (e) {
      print('Server load failed: $e');
      await _loadFromLocal();
    }
  }

  Future<void> _loadFromLocal() async {
    final localTodos = await storageService.loadTodos();
    todos.assignAll(localTodos.where((todo) => !todo.is_completed));
    completedTodos.assignAll(localTodos.where((todo) => todo.is_completed));
  }

  Future<void> _saveToLocal() async {
    final allTodos = [...todos, ...completedTodos];
    await storageService.saveTodos(allTodos);
  }

  // 添加任务
  Future<void> addTodo(Todo todo) async {
  if (authController.isLoggedIn) {
    try {
      await _addToServer(todo);
    } catch (e) {
      print('Server add failed: $e');
      await _addToLocal(todo); // 保存到本地
    }
  } else {
    await _addToLocal(todo); // 保存到本地
  }
  }

  Future<void> _addToServer(Todo todo) async {
    try {
      final response = await GetConnect().post(
        ApiConfig.createTodos(),
        todo.toJson(),
        headers: {'Authorization': 'Bearer ${authController.token}'},
      );

      if (response.hasError) {
        throw 'Failed to add todo to server';
      }

      // 在这里处理服务器返回的任务数据
      final serverTodo = Todo.fromJson(response.body['data']);
      // 根据需要执行其他操作，如替换本地任务 ID
      _replaceLocalTodo(todo, serverTodo);

    } catch (e) {
      print('Server add failed: $e');
      throw e; // 将异常抛出，由 addTodo 处理
    }
  }

  Future<void> _addToLocal(Todo todo) async {
    // 只有当任务没有 id（即本地创建的）且 localId 为空时，才生成 localId
    if (todo.id.isEmpty && (todo.local_id.isEmpty)) {
      todo = todo.copyWith(local_id: const Uuid().v4());
    }

    if (todo.is_completed) {
      completedTodos.add(todo);
    } else {
      todos.add(todo);
    }
    await _saveToLocal();
  }

  // 更新任务
  Future<void> updateTodo(Todo todo) async {
    try {
      if (authController.isLoggedIn) {
        final response = await GetConnect().put(
          ApiConfig.getTodoById(todo.id),
          todo.toJson(),
          headers: {'Authorization': 'Bearer ${authController.token}'},
        );

        if (response.hasError) {
          throw 'Failed to update todo on server';
        }
        // WebSocket 会处理状态更新
      } else {
        _handleTodoUpdated(todo);
      }
    } catch (e) {
      print('Error updating todo: $e');
      Get.snackbar('Error', 'Failed to update todo');
    }
  }

  // 删除任务
  Future<void> deleteTodo(String id) async {
    try {
      if (authController.isLoggedIn) {
        final response = await GetConnect().delete(
          // 'http://localhost:8080/api/todos/$id',
          ApiConfig.getTodoById(id),
          headers: {'Authorization': 'Bearer ${authController.token}'},
        );

        if (response.hasError) {
          throw 'Failed to delete todo from server';
        }
        // WebSocket 会处理状态更新
      } else {
        _handleTodoDeleted(id);
      }
    } catch (e) {
      print('Error deleting todo: $e');
      Get.snackbar('Error', 'Failed to delete todo');
    }
  }

  // 切换任务完成状态
  Future<void> toggleTodo(String id) async {
    try {
      if (authController.isLoggedIn) {
        final response = await GetConnect().patch(
          // 'http://localhost:8080/api/todos/$id/toggle',
          ApiConfig.toggleTodoById(id),
          null,
          headers: {'Authorization': 'Bearer ${authController.token}'},
        );

        if (response.hasError) {
          throw 'Failed to toggle todo on server';
        }
        // WebSocket 会处理状态更新
      } else {
        var todo = todos.firstWhere(
          (t) => t.id.toString() == id,
          orElse: () => completedTodos.firstWhere((t) => t.id.toString() == id),
        );
        var updatedTodo = todo.copyWith(is_completed: !todo.is_completed);
        _handleTodoUpdated(updatedTodo);
      }
    } catch (e) {
      print('Error toggling todo: $e');
      Get.snackbar('Error', 'Failed to toggle todo');
    }
  }

  // 切换收藏状态
  Future<void> toggleFavorite(String id) async {
    try {
      if (authController.isLoggedIn) {
        final response = await GetConnect().patch(
          // 'http://localhost:8080/api/todos/$id/favorite',
          ApiConfig.favoriteTodoById(id),
          null,
          headers: {'Authorization': 'Bearer ${authController.token}'},
        );

        if (response.hasError) {
          throw 'Failed to toggle favorite on server';
        }
        // WebSocket 会处理状态更新
      } else {
        var todo = todos.firstWhere(
          (t) => t.id.toString() == id,
          orElse: () => completedTodos.firstWhere((t) => t.id.toString() == id),
        );
        var updatedTodo = todo.copyWith(is_favorite: !todo.is_favorite);
        _handleTodoUpdated(updatedTodo);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      Get.snackbar('Error', 'Failed to toggle favorite');
    }
  }

  //离线任务上传逻辑
  // 检查是否有未同步的任务
  bool hasUnsyncedTasks() {
    return todos.any((todo) => todo.id.isEmpty) || 
          completedTodos.any((todo) => todo.id.isEmpty);
  }


    // 同步任务
  Future<void> syncTodos() async {
    final unsyncedTodos = todos.where((todo) => todo.id.isEmpty).toList();
    final unsyncedCompletedTodos = completedTodos.where((todo) => todo.id.isEmpty).toList();
    final allUnsyncedTodos = [...unsyncedTodos, ...unsyncedCompletedTodos];

    for (final todo in allUnsyncedTodos) {
      try {
        await _addToServer(todo);
      } catch (e) {
        print('Failed to sync todo: ${todo.local_id}, error: $e');
      }
    }

    // 同步完成后重新加载任务列表
    await loadTodos();
  }

  void _replaceLocalTodo(Todo oldTodo, Todo newTodo) {
    // 在本地查找旧任务并替换为服务器返回的任务
    final index = todos.indexWhere((t) => t.local_id == oldTodo.local_id);
    if (index != -1) {
      todos[index] = newTodo;
    }

    final completedIndex = completedTodos.indexWhere((t) => t.local_id == oldTodo.local_id);
    if (completedIndex != -1) {
      completedTodos[completedIndex] = newTodo;
    }
  }


  Future<void> removeTodo(String localId) async {
    todos.removeWhere((todo) => todo.local_id == localId);
    completedTodos.removeWhere((todo) => todo.local_id == localId);
    await _saveToLocal();
  } 
}
