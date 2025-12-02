import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  late int id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  late List<int> daysOfWeek;

  @HiveField(4)
  String? time;

  @HiveField(5)
  late bool notificationEnabled;

  @HiveField(6)
  late bool isActive;

  @HiveField(7)
  late DateTime createdAt;

  Habit({
    required this.id,
    required this.title,
    this.description,
    required this.daysOfWeek,
    this.time,
    this.notificationEnabled = false,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Habit.empty();

  bool isActiveOnDay(int weekday) {
    return daysOfWeek.contains(weekday);
  }

  Habit copyWith({
    int? id,
    String? title,
    String? description,
    List<int>? daysOfWeek,
    String? time,
    bool? notificationEnabled,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      time: time ?? this.time,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Habit(id: $id, title: $title, daysOfWeek: $daysOfWeek, time: $time)';
  }
}
