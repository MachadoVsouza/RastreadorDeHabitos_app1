import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../services/hive_service.dart';
import 'notifications_provider.dart';

class HabitNotifier extends StateNotifier<List<Habit>> {
  final Ref ref;

  HabitNotifier(this.ref) : super([]) {
    _loadHabits();
  }

  void _loadHabits() {
    final habits = HiveService.habitsBox.values.toList();
    state = habits;

    ref.read(notificationsProvider.notifier).rescheduleAllNotifications(state);
  }

  Future<void> createHabit(Habit habit) async {
    final id = HiveService.generateHabitId();
    final newHabit = habit.copyWith(id: id);
    
    await HiveService.habitsBox.put(id, newHabit);
    _loadHabits();

    if (newHabit.notificationEnabled) {
      await ref.read(notificationsProvider.notifier).scheduleHabitNotification(newHabit);
    }
  }

  Future<void> updateHabit(Habit habit) async {
    await HiveService.habitsBox.put(habit.id, habit);
    _loadHabits();

    await ref.read(notificationsProvider.notifier).updateHabitNotification(habit);
  }

  Future<void> deleteHabit(int id) async {
    await ref.read(notificationsProvider.notifier).cancelHabitNotification(id);

    await HiveService.habitsBox.delete(id);
    _loadHabits();
  }

  List<Habit> getActiveHabits() {
    return state.where((h) => h.isActive).toList();
  }

  List<Habit> getHabitsForDay(int weekday) {
    return state
        .where((h) => h.isActive && h.isActiveOnDay(weekday))
        .toList();
  }

  List<Habit> getHabitsForToday() {
    final today = DateTime.now().weekday;
    return getHabitsForDay(today);
  }

  Habit? getHabitById(int id) {
    try {
      return state.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> toggleHabitActive(int id) async {
    final habit = getHabitById(id);
    if (habit != null) {
      final updated = habit.copyWith(isActive: !habit.isActive);
      await updateHabit(updated);
    }
  }

  int getActiveHabitsCount() {
    return state.where((h) => h.isActive).length;
  }
}

final habitProvider = StateNotifierProvider<HabitNotifier, List<Habit>>((ref) {
  return HabitNotifier(ref);
});

final todayHabitsProvider = Provider<List<Habit>>((ref) {
  final habits = ref.watch(habitProvider);
  final today = DateTime.now().weekday;
  return habits
      .where((h) => h.isActive && h.isActiveOnDay(today))
      .toList();
});

final activeHabitsProvider = Provider<List<Habit>>((ref) {
  final habits = ref.watch(habitProvider);
  return habits.where((h) => h.isActive).toList();
});

final activeHabitsCountProvider = Provider<int>((ref) {
  final habits = ref.watch(habitProvider);
  return habits.where((h) => h.isActive).length;
});
