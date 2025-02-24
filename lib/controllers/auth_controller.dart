import 'package:get/get.dart';
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../services/websocket_service.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  final storage = GetStorage();
  final _isLoggedIn = false.obs;
  final _token = ''.obs;

  bool get isLoggedIn => _isLoggedIn.value;
  String get token => _token.value;

  @override
  void onInit() {
    super.onInit();
    print('AuthController: Initializing...');
    _initToken();
  }

  void _initToken() {
    final savedToken = storage.read('token');
    if (savedToken != null) {
      _token.value = savedToken;
      _isLoggedIn.value = true;
      print('AuthController: Token loaded, isLoggedIn: $isLoggedIn');
    }
  }

 Future<void> login(String username, String password) async {
  print('AuthController: Attempting login...');
  try {
    print('AuthController: Login $username, $password');

    final response = await http.post(
      Uri.parse('http://localhost:8080/api/login'),  // Android 模拟器改为10.0.2.2
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        "email": username,
        'password': password,
      }),
    );      

    // ❌ `hasError` 和 `statusText` 不适用于 `http`
    if (response.statusCode != 200) {
      throw 'Login failed: ${response.statusCode}, ${response.body}';
    }

    // ✅ 解析 JSON
    final responseData = jsonDecode(response.body);
    final token = responseData['token'] as String?;

    if (token == null) {
      throw 'Token not found in response';
    }

    await setToken(token);  // 假设 `setToken()` 是你存储 token 的方法
    
    Get.offAllNamed('/');
    print('AuthController: Login successful');
  } catch (e) {
    print('AuthController: Login failed: $e');
    Get.snackbar(
      'Login Failed',
      'Please check your credentials and try again',
      snackPosition: SnackPosition.BOTTOM,
    );
    rethrow;
  }
}

  Future<void> setToken(String newToken) async {
    print('AuthController: Setting new token...');
    _token.value = newToken;
    _isLoggedIn.value = true;
    await storage.write('token', newToken);
    print('AuthController: Token set successfully');
    
    // 设置 token 后立即连接 WebSocket
    await connectWebSocket();
  }

  Future<void> clearToken() async {
    print('AuthController: Clearing token...');
    _token.value = '';
    _isLoggedIn.value = false;
    await storage.remove('token');
    print('AuthController: Token cleared');
    
    // 断开 WebSocket 连接
    final wsService = Get.find<WebSocketService>();
    await wsService.disconnect();
  }

  Future<void> connectWebSocket() async {
    if (isLoggedIn) {
      print('AuthController: Connecting WebSocket...');
      try {
        print('AuthController: Using token: ${_token.value}');
        final wsService = Get.find<WebSocketService>();
        await wsService.connect(_token.value);
      } catch (e, stackTrace) {
        print('AuthController: Error connecting WebSocket: $e');
        print('AuthController: Stack trace: $stackTrace');
      }
    } else {
      print('AuthController: Not connecting WebSocket - user not logged in');
    }
  }

  Future<void> logout() async {
    print('AuthController: Logging out...');
    try {
      if (isLoggedIn) {
        // 调用登出接口
        final response = await GetConnect().post(
          'http://localhost:8080/api/logout',
          null,
          headers: {
            'Authorization': 'Bearer ${_token.value}',
          },
        );
        
        if (response.hasError) {
          print('AuthController: Logout API call failed: ${response.statusText}');
        }
      }
    } catch (e) {
      print('AuthController: Error during logout: $e');
    } finally {
      // 无论服务器响应如何，都清除本地状态
      await clearToken();
      Get.offAllNamed('/login');
      print('AuthController: Logged out and navigated to login');
    }
  }
}