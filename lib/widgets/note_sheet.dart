import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoteSheet extends StatefulWidget {
  final String? initialNote;
  final Function(String) onSave;

  const NoteSheet({
    super.key,
    this.initialNote,
    required this.onSave,
  });

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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Note',
              style: TextStyle(color: Colors.black),
            ),
            leading: TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              TextButton(
                child: const Text('Done'),
                onPressed: () {
                  widget.onSave(_noteController.text.trim());
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _noteController,
              autofocus: true,
              maxLines: null,
              decoration:  InputDecoration(
                hintText: 'add_note'.tr,
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                TextButton(
                  child: const Text('Body'),
                  onPressed: () {
                    // TODO: 实现格式选项
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.format_bold),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.format_italic),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.format_underline),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.format_list_bulleted),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.format_list_numbered),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.link),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}