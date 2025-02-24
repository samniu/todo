import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:get/get.dart';
import '../controllers/todo_controller.dart';
import '../controllers/auth_controller.dart';

class WebSocketService extends GetxService {
  WebSocketChannel? channel;
  final _isConnected = false.obs;
  RxBool get isConnected => _isConnected;

  Future<void> connect(String token) async {
    if (_isConnected.value) {
      print('WebSocketService: Already connected');
      return;
    }

    try {
      print('WebSocketService: Initiating connection...');
      
      final wsUrl = Uri.parse('ws://localhost:8080/api/ws');
      channel = WebSocketChannel.connect(wsUrl);

      // 等待连接建立
      await channel!.ready;
      print('WebSocketService: Connection established, sending auth message');

      // 修改认证消息格式，确保和后端匹配
      final authMessage = {
        'type': 'auth',
        'token': token
      };
      print('WebSocketService: Sending auth message: $authMessage');
      channel!.sink.add(json.encode(authMessage));
      print('WebSocketService: Auth message sent');

      // 设置消息监听
      channel!.stream.listen(
        (message) {
          try {
            final data = json.decode(message);
            if (data['type'] == 'auth_success') {
              _isConnected.value = true;  // 只在认证成功后设置为连接状态
              print('WebSocket authenticated successfully');
            } else {
              final todoController = Get.find<TodoController>();
              todoController.handleWebSocketMessage(data['type'], data['data']);
            }
          } catch (e) {
            print('Error handling message: $e');
          }
        },
        onError: (error, stackTrace) {
          print('WebSocketService: Stream error: $error');
          print('WebSocketService: Stack trace: $stackTrace');
          _handleConnectionError(error, token);
        },
        onDone: () {
          print('WebSocketService: Connection closed');
          _isConnected.value = false;
          _scheduleReconnect(token);
        },
        cancelOnError: false,
      );

      _isConnected.value = true;
      print('WebSocketService: Setup completed successfully');
      
    } catch (e, stackTrace) {
      print('WebSocketService: Connection error: $e');
      print('WebSocketService: Stack trace: $stackTrace');
      _handleConnectionError(e, token);
      rethrow;
    }
  }

  void _handleConnectionError(dynamic error, String token) {
    _isConnected.value = false;
    
    if (error.toString().contains('401') || error.toString().contains('Unauthorized')) {
      print('WebSocketService: Authentication failed');
      final authController = Get.find<AuthController>();
      authController.logout();
      Get.snackbar(
        'Session Expired',
        'Please login again',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      print('WebSocketService: Non-authentication error, scheduling reconnect');
      _scheduleReconnect(token);
    }
  }

  void _scheduleReconnect(String token) {
    if (!_isConnected.value) {
      print('WebSocketService: Scheduling reconnection...');
      Future.delayed(const Duration(seconds: 5), () {
        if (!_isConnected.value) {
          print('WebSocketService: Attempting reconnection');
          connect(token).catchError((e) {
            print('WebSocketService: Reconnection failed: $e');
          });
        }
      });
    }
  }

  Future<void> disconnect() async {
    print('WebSocketService: Disconnecting...');
    await channel?.sink.close();
    channel = null;
    _isConnected.value = false;
    print('WebSocketService: Disconnected');
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}