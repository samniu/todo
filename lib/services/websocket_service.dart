import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:get/get.dart';
import '../models/todo.dart';
import '../controllers/todo_controller.dart';

class WebSocketService extends GetxService {
  WebSocketChannel? channel;
  final _isConnected = false.obs;
  bool get isConnected => _isConnected.value;
  
  Future<void> connect(String token) async {
    if (_isConnected.value) return;

    try {
      // 使用 compute 或 Isolate 进行连接
      await Future(() async {
        final wsUrl = Uri.parse('ws://localhost:8080/api/ws');
        channel = WebSocketChannel.connect(wsUrl);
        
        // 等待连接建立
        await channel?.ready;

        // 添加认证头
        channel?.sink.add(json.encode({
          'type': 'auth',
          'token': token,
        }));

        // 监听消息
        channel?.stream.listen(
          (message) {
            try {
              final data = json.decode(message);
              _handleWebSocketMessage(data);
            } catch (e) {
              print('Error handling message: $e');
            }
          },
          onError: (error) {
            print('WebSocket Error: $error');
            _isConnected.value = false;
            _scheduleReconnect(token);
          },
          onDone: () {
            print('WebSocket connection closed');
            _isConnected.value = false;
            _scheduleReconnect(token);
          },
        );

        _isConnected.value = true;
        print('WebSocket connected successfully');
      });
    } catch (e) {
      print('Connection error: $e');
      _scheduleReconnect(token);
    }
  }

  void _scheduleReconnect(String token) {
    if (!_isConnected.value) {
      Future.delayed(const Duration(seconds: 5), () {
        connect(token);
      });
    }
  }

  void _handleWebSocketMessage(Map<String, dynamic> data) {
    // 使用 GetX 的方式获取 controller
    final todoController = Get.find<TodoController>();
    
    // 将消息处理放到下一个 Frame
    Future.microtask(() {
      switch (data['type']) {
        case 'todo_created':
          final todo = Todo.fromJson(data['data']);
          todoController.addTodo(todo);
          break;
        
        case 'todo_updated':
          final todo = Todo.fromJson(data['data']);
          todoController.updateTodo(todo);
          break;
        
        case 'todo_deleted':
          final todoId = data['data'] as String;
          todoController.deleteTodo(todoId);
          break;
        
        case 'todo_completed':
          final todo = Todo.fromJson(data['data']);
          todoController.updateTodo(todo);
          break;

        case 'todo_favorite_changed':
          final todo = Todo.fromJson(data['data']);
          todoController.toggleFavorite(todo.id);
          break;
      }
    });
  }

  Future<void> disconnect() async {
    await channel?.sink.close();
    channel = null;
    _isConnected.value = false;
    print('WebSocket disconnected');
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}