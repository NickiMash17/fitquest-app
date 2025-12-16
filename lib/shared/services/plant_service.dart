import 'package:injectable/injectable.dart';
import 'package:fitquest/core/constants/app_constants.dart';
import 'package:fitquest/shared/services/xp_calculator_service.dart';

/// Service for managing plant growth, health, and evolution
@lazySingleton
class PlantService {
  final XpCalculatorService _xpCalculator;

  PlantService(this._xpCalculator);

  /// Calculate plant evolution stage from user level
  /// Level 1-2: Seedling | Level 3-5: Sprout | Level 6-10: Sapling |
  /// Level 11-20: Young | Level 21-35: Mature | Level 36+: Majestic
  int calculateEvolutionStageFromLevel(int level) {
    return _xpCalculator.calculateEvolutionStage(level);
  }

  /// Calculate plant evolution stage from XP (legacy method for backward compatibility)
  int calculateEvolutionStage(int plantXp) {
    // For backward compatibility, estimate level from XP
    // This is approximate - ideally use level directly
    final estimatedLevel = (plantXp / 100).floor() + 1;
    return calculateEvolutionStageFromLevel(estimatedLevel);
  }

  /// Get evolution stage name
  String getEvolutionStageName(int stage) {
    return _xpCalculator.getEvolutionStageName(stage);
  }

  /// Calculate XP required for next evolution stage
  int xpRequiredForNextStage(int currentXp) {
    final currentStage = calculateEvolutionStage(currentXp);

    switch (currentStage) {
      case 1: // Seed -> Sprout
        return AppConstants.sproutStageThreshold - currentXp;
      case 2: // Sprout -> Sapling
        return AppConstants.saplingStageThreshold - currentXp;
      case 3: // Sapling -> Tree
        return AppConstants.treeStageThreshold - currentXp;
      case 4: // Tree -> Ancient Tree
        return AppConstants.ancientTreeStageThreshold - currentXp;
      case 5: // Ancient Tree (max stage)
        return 0; // Already at max
      default:
        return AppConstants.sproutStageThreshold - currentXp;
    }
  }

  /// Check if plant should evolve
  bool shouldEvolve(int currentXp, int previousXp) {
    final currentStage = calculateEvolutionStage(currentXp);
    final previousStage = calculateEvolutionStage(previousXp);
    return currentStage > previousStage;
  }

  /// Calculate plant health based on last activity date
  /// Health decreases by 5% per day without activity, minimum 0%
  int calculatePlantHealth(DateTime? lastActivityDate, int currentHealth) {
    if (lastActivityDate == null) {
      return 0;
    }

    final now = DateTime.now();
    final daysSinceActivity = now.difference(lastActivityDate).inDays;

    if (daysSinceActivity == 0) {
      // Activity today - health is at max
      return 100;
    }

    // Health decreases by 5% per day, minimum 0%
    final healthDecay = daysSinceActivity * 5;
    final newHealth = (currentHealth - healthDecay).clamp(0, 100);

    return newHealth;
  }

  /// Get plant mood based on health and activity consistency
  PlantMood getPlantMood(int health, int streak) {
    if (health >= 80 && streak >= 7) {
      return PlantMood.excellent;
    } else if (health >= 60 && streak >= 3) {
      return PlantMood.happy;
    } else if (health >= 40) {
      return PlantMood.neutral;
    } else if (health >= 20) {
      return PlantMood.sad;
    } else {
      return PlantMood.wilting;
    }
  }

  /// Get plant growth progress (0.0 to 1.0)
  double getGrowthProgress(int currentXp, int currentStage) {
    int stageStartXp;
    int stageEndXp;

    switch (currentStage) {
      case 1: // Seed
        stageStartXp = AppConstants.seedStageThreshold;
        stageEndXp = AppConstants.sproutStageThreshold;
        break;
      case 2: // Sprout
        stageStartXp = AppConstants.sproutStageThreshold;
        stageEndXp = AppConstants.saplingStageThreshold;
        break;
      case 3: // Sapling
        stageStartXp = AppConstants.saplingStageThreshold;
        stageEndXp = AppConstants.treeStageThreshold;
        break;
      case 4: // Tree
        stageStartXp = AppConstants.treeStageThreshold;
        stageEndXp = AppConstants.ancientTreeStageThreshold;
        break;
      case 5: // Ancient Tree
        return 1.0; // Max stage
      default:
        stageStartXp = 0;
        stageEndXp = AppConstants.sproutStageThreshold;
    }

    if (stageEndXp == stageStartXp) return 1.0;

    final progress = (currentXp - stageStartXp) / (stageEndXp - stageStartXp);
    return progress.clamp(0.0, 1.0);
  }

  /// Get motivational message based on plant state
  String getMotivationalMessage(int health, int streak, int stage) {
    if (health < 20) {
      return 'Your plant needs care! Log an activity to help it grow 🌱';
    } else if (health < 40) {
      return 'Keep going! Your plant is waiting for you 💚';
    } else if (streak >= 7) {
      return 'Amazing streak! Your plant is thriving! 🌿';
    } else if (streak >= 3) {
      return 'Great progress! Keep it up! 🌱';
    } else if (stage >= 4) {
      return 'Your plant has grown into a beautiful tree! 🌳';
    } else {
      return 'Every activity helps your plant grow! 🌿';
    }
  }
}

/// Plant mood enum
enum PlantMood {
  excellent,
  happy,
  neutral,
  sad,
  wilting,
}

extension PlantMoodExtension on PlantMood {
  String get emoji {
    switch (this) {
      case PlantMood.excellent:
        return '🌟';
      case PlantMood.happy:
        return '😊';
      case PlantMood.neutral:
        return '🌱';
      case PlantMood.sad:
        return '😔';
      case PlantMood.wilting:
        return '🥀';
    }
  }

  String get description {
    switch (this) {
      case PlantMood.excellent:
        return 'Thriving';
      case PlantMood.happy:
        return 'Happy';
      case PlantMood.neutral:
        return 'Growing';
      case PlantMood.sad:
        return 'Needs Care';
      case PlantMood.wilting:
        return 'Wilting';
    }
  }
}
