import '../../models/habit.dart';
import '../../models/habit_log.dart';
import '../utils/date_utils.dart';

class StatsCalculator {
  static double completionRate(List<Habit> habits, List<HabitLog> logs, DateTime start, DateTime end) {
    final dates = AppDateUtils.getDateRange(start, end);
    int totalPlanned = 0;
    int totalCompleted = 0;

    for (final date in dates) {
      final weekday = date.weekday;
      final planned = habits.where((h) => h.isActive && h.isActiveOnDay(weekday)).toList();
      totalPlanned += planned.length;
      final dayLogs = logs.where((l) => AppDateUtils.isSameDay(l.date, date) && l.completed).toList();
      totalCompleted += dayLogs.where((l) => planned.any((h) => h.id == l.habitId)).length;
    }

    if (totalPlanned == 0) return 0.0;
    return totalCompleted / totalPlanned;
  }

  static int totalXP(List<HabitLog> logs, DateTime start, DateTime end) {
    final startDay = AppDateUtils.startOfDay(start);
    final endDay = AppDateUtils.endOfDay(end);
    return logs
        .where((l) => l.date.isAfter(startDay.subtract(const Duration(seconds: 1))) &&
                      l.date.isBefore(endDay.add(const Duration(seconds: 1))) &&
                      l.completed)
        .fold(0, (sum, l) => sum + l.xpGained);
  }

  static int longestStreakForHabit(List<HabitLog> logs, int habitId) {
    final completed = logs
        .where((l) => l.habitId == habitId && l.completed)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    if (completed.isEmpty) return 0;
    int best = 1;
    int current = 1;
    for (int i = 1; i < completed.length; i++) {
      final prev = completed[i - 1].date;
      final cur = completed[i].date;
      if (AppDateUtils.isSameDay(cur, prev.add(const Duration(days: 1)))) {
        current++;
        if (current > best) best = current;
      } else {
        current = 1;
      }
    }
    return best;
  }

  static Map<int, int> completionCountsByHabit(List<HabitLog> logs, DateTime start, DateTime end) {
    final map = <int, int>{};
    final startDay = AppDateUtils.startOfDay(start);
    final endDay = AppDateUtils.endOfDay(end);
    for (final l in logs) {
      if (l.completed && l.date.isAfter(startDay.subtract(const Duration(seconds: 1))) &&
          l.date.isBefore(endDay.add(const Duration(seconds: 1)))) {
        map[l.habitId] = (map[l.habitId] ?? 0) + 1;
      }
    }
    return map;
  }
}
