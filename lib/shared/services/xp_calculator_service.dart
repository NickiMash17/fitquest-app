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
  int xpRequiredForNextLevel(int currentLevel) {
    return (currentLevel * 100);
  }

  /// Calculate evolution stage from plant XP
  int calculateEvolutionStage(int plantXp) {
    if (plantXp >= AppConstants.ancientTreeStageThreshold) return 5;
    if (plantXp >= AppConstants.treeStageThreshold) return 4;
    if (plantXp >= AppConstants.saplingStageThreshold) return 3;
    if (plantXp >= AppConstants.sproutStageThreshold) return 2;
    return 1;
  }

  /// Get evolution stage name
  String getEvolutionStageName(int stage) {
    switch (stage) {
      case 1:
        return 'Seed';
      case 2:
        return 'Sprout';
      case 3:
        return 'Sapling';
      case 4:
        return 'Tree';
      case 5:
        return 'Ancient Tree';
      default:
        return 'Seed';
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

