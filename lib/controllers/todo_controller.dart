import 'package:get/get.dart';
import '../models/todo.dart';
import '../services/storage_service.dart';
import '../services/websocket_service.dart';
import '../controllers/auth_controller.dart';

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
        'http://localhost:8080/api/todos',
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
      await _addToServer(todo);
    } else {
      await _addToLocal(todo);
    }
  }

  Future<void> _addToServer(Todo todo) async {
    try {
      final response = await GetConnect().post(
        'http://localhost:8080/api/todos',
        todo.toJson(),
        headers: {'Authorization': 'Bearer ${authController.token}'},
      );

      if (response.hasError) {
        throw 'Failed to add todo to server';
      }

      // WebSocket 会处理状态更新
    } catch (e) {
      print('Server add failed: $e');
      await _addToLocal(todo);
    }
  }

  Future<void> _addToLocal(Todo todo) async {
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
          'http://localhost:8080/api/todos/${todo.id}',
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
          'http://localhost:8080/api/todos/$id',
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
          'http://localhost:8080/api/todos/$id/toggle',
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
          'http://localhost:8080/api/todos/$id/favorite',
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
}
