import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/websocket_service.dart';

class AuthController extends GetxController {
  final storage = GetStorage();
  final _isLoggedIn = false.obs;
  final _token = RxString('');
  
  bool get isLoggedIn => _isLoggedIn.value;
  String get token => _token.value;

  @override
  void onInit() {
    super.onInit();
    print('AuthController: Initializing...');
    _token.value = storage.read('token') ?? '';
    _isLoggedIn.value = _token.value.isNotEmpty;
    print('AuthController: Token loaded, isLoggedIn: ${_isLoggedIn.value}');
  }

  // 提供一个公共方法来连接 WebSocket
  void connectWebSocket() {
    if (isLoggedIn) {
      print('Connecting WebSocket...');
      try {
        // 使用异步方式连接 WebSocket
        Future(() async {
          final wsService = Get.find<WebSocketService>();
          await wsService.connect(_token.value);
        });
      } catch (e) {
        print('Error connecting WebSocket: $e');
      }
    }
  }

  Future<void> setToken(String newToken) async {
    print('Setting new token...');
    _token.value = newToken;
    _isLoggedIn.value = true;
    await storage.write('token', newToken);
    connectWebSocket();
    print('Token set and WebSocket connected');
  }

  Future<void> login(String email, String password) async {
    try {
      print('Attempting login...');
      final response = await GetConnect().post(
        'http://localhost:8080/api/login',
        {
          'email': email,
          'password': password,
        },
      );

      print('Login response: ${response.body}');

      if (response.statusCode == 200 && response.body['token'] != null) {
        await setToken(response.body['token']);
        Get.offAllNamed('/my-day');
        print('Login successful');
      } else {
        print('Login failed: ${response.statusCode}');
        throw 'Login failed';
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<void> register(String email, String password, String name) async {
    try {
      print('Attempting registration...');
      final response = await GetConnect().post(
        'http://localhost:8080/api/register',
        {
          'email': email,
          'password': password,
          'name': name,
        },
      );

      print('Registration response: ${response.body}');

      if (response.statusCode == 200 && response.body['token'] != null) {
        await setToken(response.body['token']);
        Get.offAllNamed('/my-day');
        print('Registration successful');
      } else {
        print('Registration failed: ${response.statusCode}');
        throw 'Registration failed';
      }
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    print('Logging out...');
    _token.value = '';
    _isLoggedIn.value = false;
    await storage.remove('token');
    Get.find<WebSocketService>().disconnect();
    Get.offAllNamed('/login');
    print('Logout complete');
  }

  Future<void> checkAuthStatus() async {
    if (_token.value.isNotEmpty) {
      try {
        final response = await GetConnect().get(
          'http://localhost:8080/api/check-auth',
          headers: {
            'Authorization': 'Bearer ${_token.value}',
          },
        );

        if (response.statusCode != 200) {
          await logout();
        }
      } catch (e) {
        print('Auth check error: $e');
        await logout();
      }
    }
  }

  @override
  void onClose() {
    Get.find<WebSocketService>().disconnect();
    super.onClose();
  }
}