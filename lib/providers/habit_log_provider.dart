import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit_log.dart';
import '../services/hive_service.dart';
import '../core/utils/xp_calculator.dart';
import '../core/utils/date_utils.dart';
import 'user_profile_provider.dart';
import 'habit_provider.dart';
import 'notifications_provider.dart';

class HabitLogNotifier extends StateNotifier<List<HabitLog>> {
  final Ref ref;

  HabitLogNotifier(this.ref) : super([]) {
    _loadLogs();
  }

  void _loadLogs() {
    final logs = HiveService.habitLogsBox.values.toList();
    state = logs;
  }

  Future<int> markHabitComplete(int habitId, DateTime date) async {
    final existingLog = _getLogForHabitAndDate(habitId, date);
    
    if (existingLog != null) {
      if (existingLog.completed) {
        return 0;
      }
      final xp = XPCalculator.generateRandomXP();
      final updated = existingLog.copyWith(completed: true, xpGained: xp);
      await HiveService.habitLogsBox.put(existingLog.id, updated);
      _loadLogs();
      
      await ref.read(userProfileProvider.notifier).addXP(xp);
      
      final habit = ref.read(habitProvider.notifier).getHabitById(habitId);
      if (habit != null && habit.notificationEnabled && habit.isActive) {
        await ref.read(notificationsProvider.notifier).cancelHabitNotification(habitId);
        await ref.read(notificationsProvider.notifier).scheduleHabitNotificationForTomorrow(habit);
      }

      return xp;
    } else {
      final id = HiveService.generateLogId();
      final xp = XPCalculator.generateRandomXP();
      final newLog = HabitLog(
        id: id,
        habitId: habitId,
        date: AppDateUtils.startOfDay(date),
        completed: true,
        xpGained: xp,
      );
      
      await HiveService.habitLogsBox.put(id, newLog);
      _loadLogs();
      
      await ref.read(userProfileProvider.notifier).addXP(xp);
      
      final habit = ref.read(habitProvider.notifier).getHabitById(habitId);
      if (habit != null && habit.notificationEnabled && habit.isActive) {
        await ref.read(notificationsProvider.notifier).cancelHabitNotification(habitId);
        await ref.read(notificationsProvider.notifier).scheduleHabitNotificationForTomorrow(habit);
      }

      return xp;
    }
  }

  Future<void> markHabitIncomplete(int habitId, DateTime date) async {
    final existingLog = _getLogForHabitAndDate(habitId, date);
    
    if (existingLog != null && existingLog.completed) {
      await ref.read(userProfileProvider.notifier).removeXP(existingLog.xpGained);
      
      // Atualiza o log
      final updated = existingLog.copyWith(completed: false, xpGained: 0);
      await HiveService.habitLogsBox.put(existingLog.id, updated);
      _loadLogs();

      final habit = ref.read(habitProvider.notifier).getHabitById(habitId);
      if (habit != null && habit.notificationEnabled && habit.isActive) {
        await ref.read(notificationsProvider.notifier).updateHabitNotification(habit);
      }
    }
  }

  bool isHabitCompleted(int habitId, DateTime date) {
    final log = _getLogForHabitAndDate(habitId, date);
    return log != null && log.completed;
  }

  HabitLog? _getLogForHabitAndDate(int habitId, DateTime date) {
    final targetDate = AppDateUtils.startOfDay(date);
    try {
      return state.firstWhere(
        (log) =>
            log.habitId == habitId &&
            AppDateUtils.isSameDay(log.date, targetDate),
      );
    } catch (e) {
      return null;
    }
  }

  List<HabitLog> getLogsForHabit(int habitId) {
    return state.where((log) => log.habitId == habitId).toList();
  }

  List<HabitLog> getLogsForDate(DateTime date) {
    final targetDate = AppDateUtils.startOfDay(date);
    return state
        .where((log) => AppDateUtils.isSameDay(log.date, targetDate))
        .toList();
  }

  List<HabitLog> getLogsForDateRange(DateTime start, DateTime end) {
    final startDate = AppDateUtils.startOfDay(start);
    final endDate = AppDateUtils.endOfDay(end);
    
    return state.where((log) {
      return log.date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
             log.date.isBefore(endDate.add(const Duration(seconds: 1)));
    }).toList();
  }

  List<HabitLog> getTodayCompletedLogs() {
    final today = DateTime.now();
    return getLogsForDate(today).where((log) => log.completed).toList();
  }

  int getTodayCompletedCount() {
    return getTodayCompletedLogs().length;
  }

  int getTodayTotalXP() {
    return getTodayCompletedLogs()
        .fold(0, (sum, log) => sum + log.xpGained);
  }

  int getHabitStreak(int habitId) {
    final logs = getLogsForHabit(habitId)
        .where((log) => log.completed)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (logs.isEmpty) return 0;

    int streak = 0;
    DateTime current = DateTime.now();

    for (final log in logs) {
      if (AppDateUtils.isSameDay(log.date, current) ||
          AppDateUtils.isSameDay(
              log.date, current.subtract(const Duration(days: 1)))) {
        streak++;
        current = log.date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}

final habitLogProvider =
    StateNotifierProvider<HabitLogNotifier, List<HabitLog>>((ref) {
  return HabitLogNotifier(ref);
});

final todayLogsProvider = Provider<List<HabitLog>>((ref) {
  final logs = ref.watch(habitLogProvider);
  final todayHabits = ref.watch(todayHabitsProvider);
  final todayHabitIds = todayHabits.map((h) => h.id).toSet();
  final today = DateTime.now();
  final targetDate = AppDateUtils.startOfDay(today);
  
  return logs
      .where((log) => 
          AppDateUtils.isSameDay(log.date, targetDate) && 
          log.completed &&
          todayHabitIds.contains(log.habitId))
      .toList();
});

final todayCompletedCountProvider = Provider<int>((ref) {
  final todayLogs = ref.watch(todayLogsProvider);
  return todayLogs.length;
});

final todayXPProvider = Provider<int>((ref) {
  final todayLogs = ref.watch(todayLogsProvider);
  return todayLogs.fold(0, (sum, log) => sum + log.xpGained);
});
