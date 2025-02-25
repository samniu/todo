class ApiConfig {
  // 基础 URL
  // static const String baseUrl = 'http://localhost:8080/api';
  static const String baseUrl = 'http://192.168.1.198:8080/api';

  // API 端点
  static String login() => '$baseUrl/login';  // 登录
  static String logout() => '$baseUrl/logout'; //登出
  static String createTodos() => '$baseUrl/todos'; //创建新的任务
  static String getTodos() => '$baseUrl/todos';  // 获取所有 todos
  static String getTodoById(String id) => '$baseUrl/todos/$id';  // 根据 ID 获取单个 todo
  static String toggleTodoById(String id) => '$baseUrl/todos/$id/toggle';  // 切换 todo
  static String favoriteTodoById(String id) => '$baseUrl/todos/$id/favorite';  // 收藏 todo

  // WebSocket URL
  // static const String wsUrl = 'ws://localhost:8080/api/ws';
  static const String wsUrl = 'ws://192.168.1.198:8080/api/ws';
}