import 'dart:math' as math;
import 'package:injectable/injectable.dart';
import 'package:fitquest/shared/models/activity_model.dart';
import 'package:fitquest/core/constants/app_constants.dart';

/// Service for calculating XP and points
@lazySingleton
class XpCalculatorService {
  /// Calculate XP for activity
  int calculateXp(ActivityModel activity) {
    switch (activity.type) {
      case ActivityType.exercise:
        return activity.duration * AppConstants.exerciseXpPerMinute;
      case ActivityType.meditation:
        return activity.duration * AppConstants.meditationXpPerMinute;
      case ActivityType.hydration:
        return (activity.glasses ?? 0) * AppConstants.hydrationXpPerGlass;
      case ActivityType.sleep:
        return (activity.hours ?? 0) * AppConstants.sleepXpPerHour;
    }
  }

  /// Calculate points for activity
  int calculatePoints(ActivityModel activity) {
    switch (activity.type) {
      case ActivityType.exercise:
        return activity.duration * AppConstants.exercisePointsPerMinute;
      case ActivityType.meditation:
        return activity.duration * AppConstants.meditationPointsPerMinute;
      case ActivityType.hydration:
        return (activity.glasses ?? 0) * AppConstants.hydrationPointsPerGlass;
      case ActivityType.sleep:
        return (activity.hours ?? 0) * AppConstants.sleepPointsPerHour;
    }
  }

  /// Calculate level from total XP
  int calculateLevel(int totalXp) {
    // Level formula: level = sqrt(totalXp / 100) + 1
    return (totalXp / 100).sqrt().floor() + 1;
  }

  /// Calculate XP required for next level
  /// Formula: maxXP = 100 * (1.5 ^ (level-1))
  int xpRequiredForNextLevel(int currentLevel) {
    if (currentLevel <= 1) return 100;
    // Calculate 1.5 ^ (level-1) using pow
    final multiplier = math.pow(1.5, currentLevel - 1);
    return (100 * multiplier).round();
  }
  
  /// Calculate total XP needed to reach a specific level
  int totalXpForLevel(int level) {
    if (level <= 1) return 0;
    int total = 0;
    for (int i = 1; i < level; i++) {
      total += xpRequiredForNextLevel(i);
    }
    return total;
  }

  /// Calculate evolution stage from user level
  /// Level 1-2: Seedling | Level 3-5: Sprout | Level 6-10: Sapling | 
  /// Level 11-20: Young | Level 21-35: Mature | Level 36+: Majestic
  int calculateEvolutionStage(int level) {
    if (level >= 36) return 6; // Majestic
    if (level >= 21) return 5; // Mature
    if (level >= 11) return 4; // Young
    if (level >= 6) return 3;  // Sapling
    if (level >= 3) return 2; // Sprout
    return 1; // Seedling
  }

  /// Get evolution stage name
  String getEvolutionStageName(int stage) {
    switch (stage) {
      case 1:
        return 'Seedling';
      case 2:
        return 'Sprout';
      case 3:
        return 'Sapling';
      case 4:
        return 'Young Tree';
      case 5:
        return 'Mature Tree';
      case 6:
        return 'Majestic Tree';
      default:
        return 'Seedling';
    }
  }
}

extension SqrtExtension on num {
  double sqrt() {
    // Simple square root approximation
    if (this <= 0) return 0;
    final double x = toDouble();
    double y = (x + 1) / 2;
    while ((y - x / y).abs() > 0.00001) {
      y = (y + x / y) / 2;
    }
    return y;
  }
}

