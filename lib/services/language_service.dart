import 'package:get/get.dart';

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': {
      // Task related
      'task_title': 'Title',
      'task_note': 'Note',
      'task_details': 'Task Details',
      'add_task': 'Add a Task',
      'delete_task': 'Delete Task',
      
      // Reminder related
      'remind_me': 'Remind Me',
      'reminder_set': 'Reminder set',
      'reminder_removed': 'Reminder removed',
      'reminder_today': 'Today',
      'reminder_tomorrow': 'Tomorrow',
      
      // Subtask related
      'steps': 'Steps',
      'add_step': 'Add step',
      'step_added': 'Step added',
      'step_removed': 'Step removed',
      
      // Date related
      'due_date': 'Add Due Date',
      'repeat': 'Repeat',
      'daily': 'Daily',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'yearly': 'Yearly',
      'weekdays': 'Weekdays',

      'today': 'Today',
      'tomorrow': 'Tomorrow',
      'nextweek': 'Next Week',
      'pickadate': 'Pick a Date',
      
      // General
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'done': 'Done',

      'add_file':'Add File',
    },
    'zh': {
      // Task related
      'task_title': '标题',
      'task_note': '备注',
      'task_details': '任务详情',
      'add_task': '添加任务',
      'delete_task': '删除任务',
      
      // Reminder related
      'remind_me': '提醒我',
      'reminder_set': '提醒已设置',
      'reminder_removed': '提醒已移除',
      'reminder_today': '今天',
      'reminder_tomorrow': '明天',
      
      // Subtask related
      'steps': '步骤',
      'add_step': '添加步骤',
      'step_added': '步骤已添加',
      'step_removed': '步骤已删除',
      
      // Date related
      'due_date': '截止日期',
      'repeat': '重复',
      'daily': '每天',
      'weekly': '每周',
      'monthly': '每月',
      'yearly': '每年',
      'weekdays': '工作日',
      
      'today': '今天',
      'tomorrow': '明天',
      'nextweek': '下周',
      'pickadate': '选择日期',
      
      // General
      'cancel': '取消',
      'save': '保存',
      'delete': '删除',
      'edit': '编辑',
      'done': '完成',

      'add_file':'添加文件',
    },
  };
}