import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../models/user_profile.dart';

class HiveService {
  static const String habitsBoxName = 'habits';
  static const String habitLogsBoxName = 'habitLogs';
  static const String userProfileBoxName = 'userProfile';

  static late Box<Habit> _habitsBox;
  static late Box<HabitLog> _habitLogsBox;
  static late Box<UserProfile> _userProfileBox;

  static Box<Habit> get habitsBox => _habitsBox;
  static Box<HabitLog> get habitLogsBox => _habitLogsBox;
  static Box<UserProfile> get userProfileBox => _userProfileBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(HabitAdapter());
    Hive.registerAdapter(HabitLogAdapter());
    Hive.registerAdapter(UserProfileAdapter());

    _habitsBox = await Hive.openBox<Habit>(habitsBoxName);
    _habitLogsBox = await Hive.openBox<HabitLog>(habitLogsBoxName);
    _userProfileBox = await Hive.openBox<UserProfile>(userProfileBoxName);

    if (_userProfileBox.isEmpty) {
      await _userProfileBox.put('profile', UserProfile());
    }
  }

  static int generateHabitId() {
    if (_habitsBox.isEmpty) return 1;
    final ids = _habitsBox.values.map((h) => h.id).toList();
    return (ids.reduce((a, b) => a > b ? a : b)) + 1;
  }

  static int generateLogId() {
    if (_habitLogsBox.isEmpty) return 1;
    final ids = _habitLogsBox.values.map((l) => l.id).toList();
    return (ids.reduce((a, b) => a > b ? a : b)) + 1;
  }

  static UserProfile getUserProfile() {
    return _userProfileBox.get('profile', defaultValue: UserProfile())!;
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    await _userProfileBox.put('profile', profile);
  }

  static Future<void> clearAllData() async {
    await _habitsBox.clear();
    await _habitLogsBox.clear();
    await _userProfileBox.clear();
    await _userProfileBox.put('profile', UserProfile());
  }

  static Future<void> close() async {
    await _habitsBox.close();
    await _habitLogsBox.close();
    await _userProfileBox.close();
  }
}
