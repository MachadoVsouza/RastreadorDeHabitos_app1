import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../services/notification_service.dart';
import '../core/utils/date_utils.dart';
import 'habit_log_provider.dart';

class NotificationsNotifier extends StateNotifier<bool> {
  final Ref ref;

  NotificationsNotifier(this.ref) : super(false);

  Future<void> scheduleHabitNotification(Habit habit) async {
    if (!habit.notificationEnabled || habit.time == null) return;

    final time = AppDateUtils.parseTime(habit.time);
    if (time == null) return;

    final isCompletedToday = ref
        .read(habitLogProvider.notifier)
        .isHabitCompleted(habit.id, DateTime.now());
    if (isCompletedToday) return;

    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await NotificationService.scheduleHabitNotification(
      id: habit.id,
      title: 'Hora do hábito!',
      body: 'Hábito: ${habit.title}',
      scheduledTime: scheduledTime,
    );
  }

  Future<void> cancelHabitNotification(int habitId) async {
    await NotificationService.cancelNotification(habitId);
  }

  Future<void> rescheduleAllNotifications(List<Habit> habits) async {
    await NotificationService.cancelAllNotifications();

    for (final habit in habits) {
      if (habit.isActive && habit.notificationEnabled && habit.time != null) {
        final isCompletedToday = ref
            .read(habitLogProvider.notifier)
            .isHabitCompleted(habit.id, DateTime.now());
        if (!isCompletedToday) {
          await scheduleHabitNotification(habit);
        }
      }
    }
  }

  Future<void> updateHabitNotification(Habit habit) async {
    await cancelHabitNotification(habit.id);

    if (habit.isActive && habit.notificationEnabled) {
      await scheduleHabitNotification(habit);
    }
  }

  Future<void> scheduleHabitNotificationForTomorrow(Habit habit) async {
    if (!habit.notificationEnabled || habit.time == null) return;

    final time = AppDateUtils.parseTime(habit.time);
    if (time == null) return;

    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    ).add(const Duration(days: 1));

    await NotificationService.scheduleHabitNotification(
      id: habit.id,
      title: 'Hora do hábito!',
      body: 'Hábito: ${habit.title}',
      scheduledTime: scheduledTime,
    );
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, bool>((ref) {
  return NotificationsNotifier(ref);
});
