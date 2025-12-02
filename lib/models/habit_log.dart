import 'package:hive/hive.dart';

part 'habit_log.g.dart';

@HiveType(typeId: 1)
class HabitLog extends HiveObject {
  @HiveField(0)
  late int id;

  @HiveField(1)
  late int habitId;

  @HiveField(2)
  late DateTime date;

  @HiveField(3)
  late bool completed;

  @HiveField(4)
  late int xpGained;

  HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.completed,
    required this.xpGained,
  });

  HabitLog.empty();

  HabitLog copyWith({
    int? id,
    int? habitId,
    DateTime? date,
    bool? completed,
    int? xpGained,
  }) {
    return HabitLog(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      xpGained: xpGained ?? this.xpGained,
    );
  }

  @override
  String toString() {
    return 'HabitLog(id: $id, habitId: $habitId, date: $date, completed: $completed, xpGained: $xpGained)';
  }
}
