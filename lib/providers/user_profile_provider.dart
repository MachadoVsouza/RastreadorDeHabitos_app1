import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/hive_service.dart';
import '../core/utils/xp_calculator.dart';

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(HiveService.getUserProfile());

  Future<LevelUpResult> addXP(int xp) async {
    final profile = state;
    final newXP = profile.xp + xp;
    
    final result = XPCalculator.calculateLevelUp(newXP, profile.level);
    
    final updated = profile.copyWith(
      xp: result.remainingXP,
      level: result.newLevel,
    );
    
    state = updated;
    await HiveService.saveUserProfile(updated);
    
    return result;
  }

  Future<void> removeXP(int xp) async {
    final profile = state;
    final newXP = (profile.xp - xp).clamp(0, double.infinity).toInt();
    
    final updated = profile.copyWith(xp: newXP);
    state = updated;
    await HiveService.saveUserProfile(updated);
  }

  Future<void> updateDisplayName(String? name) async {
    final updated = state.copyWith(displayName: name);
    state = updated;
    await HiveService.saveUserProfile(updated);
  }

  Future<void> toggleNotifications(bool enabled) async {
    final updated = state.copyWith(notificationsEnabled: enabled);
    state = updated;
    await HiveService.saveUserProfile(updated);
  }

  int getXPNeededForNextLevel() {
    return XPCalculator.calculateXPNeeded(state.level);
  }

  double getCurrentLevelProgress() {
    return XPCalculator.calculateProgress(state.xp, state.level);
  }

  Future<void> resetProfile() async {
    final newProfile = UserProfile();
    state = newProfile;
    await HiveService.saveUserProfile(newProfile);
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});

final currentLevelProvider = Provider<int>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile.level;
});

final currentXPProvider = Provider<int>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile.xp;
});

final xpNeededProvider = Provider<int>((ref) {
  final notifier = ref.watch(userProfileProvider.notifier);
  return notifier.getXPNeededForNextLevel();
});

final levelProgressProvider = Provider<double>((ref) {
  final notifier = ref.watch(userProfileProvider.notifier);
  return notifier.getCurrentLevelProgress();
});

final notificationsEnabledProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile.notificationsEnabled;
});
