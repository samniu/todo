import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get_storage/get_storage.dart';

import 'services/storage_service.dart';
import 'screens/my_day_page.dart';
import 'screens/login_page.dart';
import 'services/language_service.dart';
import 'controllers/quick_add_controller.dart';
import 'services/websocket_service.dart';
import 'controllers/todo_controller.dart';
import 'controllers/auth_controller.dart';

void main() async {
  // 确保 Flutter 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化所有必要的服务
  await Future.wait([
    GetStorage.init(),
    initializeDateFormatting('en', null),
    initializeDateFormatting('zh', null),
  ]);

  // 初始化存储服务
  final storageService = await StorageService.init();

  // 按照依赖顺序初始化控制器和服务
  Get.put(storageService);          // 1. 存储服务
  Get.put(WebSocketService());      // 2. WebSocket 服务
  Get.put(QuickAddController());    // 3. 快速添加控制器
  Get.put(AuthController()); // 4. 认证控制器
  Get.put(TodoController());        // 5. Todo 控制器

  runApp(MyApp(storageService: storageService));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;

  const MyApp({
    super.key,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Todo',
      // 语言配置
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      translations: Messages(),

      // 主题配置
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      // 路由配置
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => GetX<AuthController>(
            builder: (controller) {
              return controller.isLoggedIn 
                  ? MyDayPage(storageService: storageService)
                  : LoginPage();
            },
          ),
        ),
        GetPage(
          name: '/login',
          page: () => LoginPage(),
        ),
        GetPage(
          name: '/my-day',
          page: () => MyDayPage(storageService: storageService),
        ),
      ],

      // 调试设置
      debugShowCheckedModeBanner: false,
    );
  }
}