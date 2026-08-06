import 'package:life_task_manager/features/notifications/data/notification_service.dart';
import 'package:life_task_manager/features/tasks/domain/entities/task_entity.dart';

/// タスク作成・更新時にローカル通知を自動スケジュールするユーティリティ
class LocalNotificationScheduler {
  const LocalNotificationScheduler._();

  /// タスクの [reminderDaysBefore] に基づき通知をスケジュール
  ///
  /// reminderDaysBefore == 0 → 期限当日の朝 9:00
  /// reminderDaysBefore > 0  → 期限 N 日前の朝 9:00
  static Future<void> scheduleForTask(TaskEntity task) async {
    if (task.isArchived) {
      await NotificationService.cancelTaskReminder(task.taskId);
      return;
    }

    final reminderAt = _calcReminderTime(task.nextDueAt, task.reminderDaysBefore);
    await NotificationService.scheduleTaskReminder(
      taskId: task.taskId,
      title: task.title,
      scheduledTime: reminderAt,
      cost: task.cost,
    );
  }

  /// タスク完了・削除時に通知をキャンセル
  static Future<void> cancelForTask(String taskId) async {
    await NotificationService.cancelTaskReminder(taskId);
  }

  static DateTime _calcReminderTime(DateTime dueAt, int daysBefore) {
    final base = dueAt.subtract(Duration(days: daysBefore));
    return DateTime(base.year, base.month, base.day, 9, 0, 0);
  }
}
