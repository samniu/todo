// lib/widgets/repeat_sheet.dart
import 'package:flutter/material.dart';
import '../models/repeat_type.dart';

class RepeatSheet extends StatefulWidget {
  final RepeatType? initialRepeatType;
  final void Function(RepeatType?) onSave;

  const RepeatSheet({
    super.key,
    this.initialRepeatType,
    required this.onSave,
  });

  @override
  State<RepeatSheet> createState() => _RepeatSheetState();
}

class _RepeatSheetState extends State<RepeatSheet> {
  final int? _repeatCount = 1;
  RepeatType? _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialRepeatType;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Repeat every...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    child: const Text(
                      'Set',
                      style: TextStyle(color: Colors.blue),
                    ),
                    onPressed: () {
                      widget.onSave(_selectedType);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text(
                'Daily',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                setState(() {
                  _selectedType = RepeatType.daily;
                });
                widget.onSave(RepeatType.daily);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text(
                'Weekly',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                setState(() {
                  _selectedType = RepeatType.weekly;
                });
                widget.onSave(RepeatType.weekly);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text(
                'Weekdays',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                setState(() {
                  _selectedType = RepeatType.weekdays;
                });
                widget.onSave(RepeatType.weekdays);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text(
                'Monthly',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                setState(() {
                  _selectedType = RepeatType.monthly;
                });
                widget.onSave(RepeatType.monthly);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text(
                'Yearly',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                setState(() {
                  _selectedType = RepeatType.yearly;
                });
                widget.onSave(RepeatType.yearly);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}