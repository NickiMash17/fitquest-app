// lib/features/home/domain/usecases/calculate_tree_stage.dart
import 'dart:math' as math;
import 'package:fitquest/features/home/data/models/wellness_data.dart';
import 'package:fitquest/features/home/domain/entities/tree_stage.dart';

/// Tree stage calculator with balance scoring
class TreeCalculator {
  static TreeStage getStageForLevel(int level, WellnessData data) {
    // Calculate enhanced stage based on level AND wellness balance
    final baseStage = _getBaseStageForLevel(level);

    // Enhance or reduce based on wellness balance
    final balanceScore = _calculateBalanceScore(data);

    return baseStage.copyWith(
      trunkWidth: baseStage.trunkWidth * (0.8 + balanceScore * 0.4),
      canopyRadiusRatio:
          baseStage.canopyRadiusRatio * (0.7 + balanceScore * 0.6),
    );
  }

  static TreeStage _getBaseStageForLevel(int level) {
    if (level <= 2) {
      return TreeStage.seedling();
    } else if (level <= 5) {
      return TreeStage.sprout();
    } else if (level <= 10) {
      return TreeStage.sapling();
    } else if (level <= 20) {
      return TreeStage.youngTree();
    } else if (level <= 35) {
      return TreeStage.mature();
    } else {
      return TreeStage.majestic();
    }
  }

  static double _calculateBalanceScore(WellnessData data) {
    // Calculate how balanced the user's wellness is (0.0 - 1.0)
    final scores = [
      data.exerciseConsistency,
      data.meditationRegularity,
      data.hydrationLevel,
      data.sleepQuality,
    ];

    final average = scores.reduce((a, b) => a + b) / scores.length;
    final variance =
        scores.map((s) => math.pow(s - average, 2)).reduce((a, b) => a + b) /
            scores.length;

    // Lower variance = better balance
    return 1.0 - math.min(variance, 1.0);
  }
}
