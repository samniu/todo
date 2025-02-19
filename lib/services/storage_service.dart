import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class StorageService {
  static const String _todoKey = 'todos';
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  Future<List<Todo>> loadTodos() async {
    final todoStrings = _prefs.getStringList(_todoKey) ?? [];
    return todoStrings
        .map((str) => Todo.fromJson(jsonDecode(str)))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveTodos(List<Todo> todos) async {
    final todoStrings = todos
        .map((todo) => jsonEncode(todo.toJson()))
        .toList();
    await _prefs.setStringList(_todoKey, todoStrings);
  }
}