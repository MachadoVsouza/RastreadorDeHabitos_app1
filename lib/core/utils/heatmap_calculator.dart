import '../../models/habit_log.dart';
import '../utils/date_utils.dart';

class HeatmapCalculator {
  static Map<DateTime, int> generateHeatmapData(List<HabitLog> logs) {
    final map = <DateTime, int>{};
    
    for (final log in logs) {
      if (!log.completed) continue;
      
      final day = AppDateUtils.startOfDay(log.date);
      map[day] = (map[day] ?? 0) + 1;
    }
    
    return map;
  }

  static Map<DateTime, int> generateHabitHeatmapData(List<HabitLog> logs, int habitId) {
    final filtered = logs.where((l) => l.habitId == habitId && l.completed).toList();
    return generateHeatmapData(filtered);
  }

  static int getTotalCompletions(Map<DateTime, int> heatmapData, DateTime start, DateTime end) {
    final startDay = AppDateUtils.startOfDay(start);
    final endDay = AppDateUtils.endOfDay(end);
    
    int total = 0;
    for (final entry in heatmapData.entries) {
      if (entry.key.isAfter(startDay.subtract(const Duration(seconds: 1))) &&
          entry.key.isBefore(endDay.add(const Duration(seconds: 1)))) {
        total += entry.value;
      }
    }
    return total;
  }

  static int getLongestStreak(Map<DateTime, int> heatmapData) {
    if (heatmapData.isEmpty) return 0;
    
    final sortedDates = heatmapData.keys.toList()..sort();
    int longest = 1;
    int current = 1;
    
    for (int i = 1; i < sortedDates.length; i++) {
      final prev = sortedDates[i - 1];
      final curr = sortedDates[i];
      
      if (AppDateUtils.isSameDay(curr, prev.add(const Duration(days: 1)))) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    
    return longest;
  }

  static int getCurrentStreak(Map<DateTime, int> heatmapData) {
    if (heatmapData.isEmpty) return 0;
    
    final today = AppDateUtils.startOfDay(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (!heatmapData.containsKey(today) && !heatmapData.containsKey(yesterday)) {
      return 0;
    }
    
    int streak = 0;
    DateTime current = heatmapData.containsKey(today) ? today : yesterday;
    
    while (heatmapData.containsKey(current)) {
      streak++;
      current = current.subtract(const Duration(days: 1));
    }
    
    return streak;
  }
}
