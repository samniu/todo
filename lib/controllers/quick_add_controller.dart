import 'package:get/get.dart';

class QuickAddController extends GetxController {
  // 可观察变量
  final _title = RxString('');
  final _note = Rxn<String>();
  final _selectedDate = Rxn<DateTime>();

  // Getters
  String get title => _title.value;
  String? get note => _note.value;
  DateTime? get selectedDate => _selectedDate.value;

  // Setters
  void setTitle(String value) => _title.value = value;
  void setNote(String? value) => _note.value = value;
  void setSelectedDate(DateTime? value) => _selectedDate.value = value;

  // 清除所有数据
  void clearAll() {
    _title.value = '';
    _note.value = null;
    _selectedDate.value = null;
  }
}