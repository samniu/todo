import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';  // 导入日期格式化初始化库

import 'services/storage_service.dart';
import 'screens/my_day_page.dart';
import 'services/language_service.dart';
import 'controllers/quick_add_controller.dart';


void main() async {
    // 初始化语言环境数据
  await initializeDateFormatting('en', null);  // 默认语言为英文
  await initializeDateFormatting('zh', null);  // 中文

  Get.put(QuickAddController());
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await StorageService.init();
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
      locale: Get.deviceLocale,  // 设备语言
      fallbackLocale: const Locale('en', 'US'),  // 默认语言  
      // locale: Locale('zh', 'CN'),  // 设置默认语言为简体中文
      // fallbackLocale: Locale('zh', 'CN'),  // 设置备用语言为简体中文    
      translations: Messages(),  // 你的翻译
      title: 'Flutter Todo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: MyDayPage(storageService: storageService),
    );
  }
}