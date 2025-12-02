import 'dart:math';

class XPCalculator {
  static int calculateXPNeeded(int level) {
    return level * 100;
  }

  static int generateRandomXP() {
    final random = Random();
    return 5 + random.nextInt(11);
  }

  static double calculateProgress(int currentXP, int level) {
    final xpNeeded = calculateXPNeeded(level);
    if (xpNeeded == 0) return 0.0;
    return (currentXP / xpNeeded).clamp(0.0, 1.0);
  }

  static LevelUpResult calculateLevelUp(int currentXP, int currentLevel) {
    int xp = currentXP;
    int level = currentLevel;

    while (xp >= calculateXPNeeded(level)) {
      xp -= calculateXPNeeded(level);
      level++;
    }

    return LevelUpResult(
      newLevel: level,
      remainingXP: xp,
      levelsGained: level - currentLevel,
    );
  }

  static int totalXPForLevel(int targetLevel) {
    int total = 0;
    for (int i = 1; i < targetLevel; i++) {
      total += calculateXPNeeded(i);
    }
    return total;
  }

  static String getMotivationalMessage(int xp) {
    if (xp >= 13) {
      return '🔥 Incrível! +$xp XP';
    } else if (xp >= 10) {
      return '⭐ Muito bem! +$xp XP';
    } else if (xp >= 7) {
      return '👍 Bom trabalho! +$xp XP';
    } else {
      return '✓ Parabéns! +$xp XP';
    }
  }
}

class LevelUpResult {
  final int newLevel;
  final int remainingXP;
  final int levelsGained;

  LevelUpResult({
    required this.newLevel,
    required this.remainingXP,
    required this.levelsGained,
  });

  bool get hasLeveledUp => levelsGained > 0;
}
