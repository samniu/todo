import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class DateFormatter {
  static String formatTaskDate(DateTime? date) {
    if (date == null) return '';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'today'.tr;
    } else if (dateOnly == tomorrow) {
      return 'tomorrow'.tr;
    } else {
      // return DateFormat('MM月dd日').format(date);
      return getLocalizedDate(date,'EEE, MMM d');
    }
  }

  static String getDayName(DateTime date) {
    // return DateFormat('E').format(date);  // 返回简短的星期名
    return getLocalizedDate(date,'E');
  }

  static String formatCreatedTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      // return DateFormat('yyyy/MM/dd').format(dateTime);
      return getLocalizedDate(dateTime,'yyyy/MM/dd');
    }
  }  

  static String getLocalizedDate(DateTime date,String? pattern, ) {
    // 获取当前语言环境
    final locale = Get.locale ?? Locale('en');  // 默认语言为英文
    // 格式化日期
    final dateFormat = DateFormat(pattern, locale.toString());  // 使用当前语言环境
    return dateFormat.format(date);
  }
}