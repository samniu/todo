import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoteSheet extends StatefulWidget {
  final String? initialNote;
  final Function(String) onSave;

  const NoteSheet({super.key, this.initialNote, required this.onSave});

  @override
  State<NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<NoteSheet> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Note', style: TextStyle(color: Colors.black)),
        leading: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero, // 移除默认的内边距
            minimumSize: Size.zero, // 设置最小尺寸为零
          ),
          child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            child: const Text('Done', style: TextStyle(color: Colors.blue)),
            onPressed: () {
              widget.onSave(_noteController.text.trim());
              Navigator.pop(context);
            },
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _noteController,
                autofocus: true,
                maxLines: null,
                style: const TextStyle(color: Colors.black), // 设置文本颜色
                decoration: InputDecoration(
                  hintText: 'add_note'.tr,
                  hintStyle: TextStyle(color: Colors.grey[400]), // 设置提示文本颜色
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
