import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 2)
class UserProfile extends HiveObject {
  @HiveField(0)
  late int xp;

  @HiveField(1)
  late int level;

  @HiveField(2)
  String? displayName;

  @HiveField(3)
  late bool notificationsEnabled;

  @HiveField(4)
  late DateTime createdAt;

  UserProfile({
    this.xp = 0,
    this.level = 1,
    this.displayName,
    this.notificationsEnabled = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  UserProfile.empty();

  UserProfile copyWith({
    int? xp,
    int? level,
    String? displayName,
    bool? notificationsEnabled,
    DateTime? createdAt,
  }) {
    return UserProfile(
      xp: xp ?? this.xp,
      level: level ?? this.level,
      displayName: displayName ?? this.displayName,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserProfile(level: $level, xp: $xp, displayName: $displayName)';
  }
}
