import 'package:get/get.dart';
import '../models/todo.dart';
import '../services/storage_service.dart';
import '../controllers/auth_controller.dart';

class TodoController extends GetxController {
  final storageService = Get.find<StorageService>();
  final authController = Get.find<AuthController>();
  
  // 状态变量
  var todos = <Todo>[].obs;
  var completedTodos = <Todo>[].obs;
  var isLoading = false.obs;

  // 加载数据
  Future<void> loadTodos() async {
    try {
      isLoading.value = true;

      if (authController.isLoggedIn) {
        // 从服务器加载数据
        await _loadFromServer();
      } else {
        // 从本地加载数据
        await _loadFromLocal();
      }
    } catch (e) {
      print('Error loading todos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 从服务器加载数据
  Future<void> _loadFromServer() async {
    try {
      final response = await GetConnect().get(
        'http://localhost:8080/api/todos',
        headers: {
          'Authorization': 'Bearer ${authController.token}',
        },
      );

      if (response.hasError) {
        throw 'Failed to load todos from server';
      }

      final List<dynamic> todoList = response.body;
      final loadedTodos = todoList.map((json) => Todo.fromJson(json)).toList();
      
      // 更新内存中的数据
      todos.value = loadedTodos.where((todo) => !todo.isCompleted).toList();
      completedTodos.value = loadedTodos.where((todo) => todo.isCompleted).toList();
      
      // 同步到本地存储
      await _saveToLocal();
    } catch (e) {
      print('Server load failed, falling back to local: $e');
      await _loadFromLocal();
    }
  }

  // 从本地加载数据
  Future<void> _loadFromLocal() async {
    final localTodos = await storageService.loadTodos();
    todos.value = localTodos.where((todo) => !todo.isCompleted).toList();
    completedTodos.value = localTodos.where((todo) => todo.isCompleted).toList();
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
        headers: {
          'Authorization': 'Bearer ${authController.token}',
        },
      );

      if (response.hasError) {
        throw 'Failed to add todo to server';
      }

      // 使用服务器返回的数据（包含服务器生成的ID）
      final newTodo = Todo.fromJson(response.body);
      
      // 更新内存中的数据
      if (newTodo.isCompleted) {
        completedTodos.add(newTodo);
      } else {
        todos.add(newTodo);
      }

      // 同步到本地存储
      await _saveToLocal();
    } catch (e) {
      print('Server add failed, saving locally: $e');
      await _addToLocal(todo);
    }
  }

  Future<void> _addToLocal(Todo todo) async {
    if (todo.isCompleted) {
      completedTodos.add(todo);
    } else {
      todos.add(todo);
    }
    await _saveToLocal();
  }

  // 更新任务状态（切换完成状态）
  Future<void> toggleTodo(String id) async {
    if (authController.isLoggedIn) {
      await _toggleOnServer(id);
    } else {
      await _toggleLocally(id);
    }
  }

  Future<void> _toggleOnServer(String id) async {
    try {
      final response = await GetConnect().patch(
        'http://localhost:8080/api/todos/$id/toggle',
        null,
        headers: {
          'Authorization': 'Bearer ${authController.token}',
        },
      );

      if (response.hasError) {
        throw 'Failed to toggle todo on server';
      }

      // 服务器操作成功后更新本地状态
      await _toggleLocally(id);
    } catch (e) {
      print('Server toggle failed, toggling locally: $e');
      await _toggleLocally(id);
    }
  }

  Future<void> _toggleLocally(String id) async {
    var todo = todos.firstWhere(
      (t) => t.id == id,
      orElse: () => completedTodos.firstWhere((t) => t.id == id),
    );

    var updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);

    if (updatedTodo.isCompleted) {
      todos.remove(todo);
      completedTodos.add(updatedTodo);
    } else {
      completedTodos.remove(todo);
      todos.add(updatedTodo);
    }

    todos.refresh();
    completedTodos.refresh();
    await _saveToLocal();
  }

  // 保存到本地存储
  Future<void> _saveToLocal() async {
    final allTodos = [...todos, ...completedTodos];
    await storageService.saveTodos(allTodos);
  }
}