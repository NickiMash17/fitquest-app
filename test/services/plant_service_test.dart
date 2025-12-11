// test/services/plant_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fitquest/shared/services/plant_service.dart';
import 'package:fitquest/shared/services/xp_calculator_service.dart';
import 'package:fitquest/core/constants/app_constants.dart';

void main() {
  group('PlantService', () {
    late PlantService service;
    late XpCalculatorService xpCalculator;

    setUp(() {
      xpCalculator = XpCalculatorService();
      service = PlantService(xpCalculator);
    });

    group('calculateEvolutionStageFromLevel', () {
      test('delegates to XpCalculatorService correctly', () {
        expect(service.calculateEvolutionStageFromLevel(1), equals(1));
        expect(service.calculateEvolutionStageFromLevel(5), equals(2));
        expect(service.calculateEvolutionStageFromLevel(10), equals(3));
        expect(service.calculateEvolutionStageFromLevel(20), equals(4));
        expect(service.calculateEvolutionStageFromLevel(35), equals(5));
        expect(service.calculateEvolutionStageFromLevel(36), equals(6));
      });
    });

    group('calculateEvolutionStage (legacy XP-based)', () {
      test('estimates stage from XP correctly', () {
        // Stage 1: 0-19 XP
        expect(service.calculateEvolutionStage(0), equals(1));
        expect(service.calculateEvolutionStage(19), equals(1));

        // Stage 2: ~20-49 XP (estimated level 1-2)
        expect(service.calculateEvolutionStage(20), lessThanOrEqualTo(2));

        // Stage 3: ~50-99 XP (estimated level 1-2)
        expect(service.calculateEvolutionStage(50), lessThanOrEqualTo(3));
      });

      test('handles large XP values', () {
        final stage = service.calculateEvolutionStage(10000);
        expect(stage, greaterThanOrEqualTo(1));
        expect(stage, lessThanOrEqualTo(6));
      });
    });

    group('getEvolutionStageName', () {
      test('returns correct names for all stages', () {
        expect(service.getEvolutionStageName(1), equals('Seedling'));
        expect(service.getEvolutionStageName(2), equals('Sprout'));
        expect(service.getEvolutionStageName(3), equals('Sapling'));
        expect(service.getEvolutionStageName(4), equals('Young Tree'));
        expect(service.getEvolutionStageName(5), equals('Mature Tree'));
        expect(service.getEvolutionStageName(6), equals('Majestic Tree'));
      });
    });

    group('xpRequiredForNextStage', () {
      test('returns correct XP for stage 1 (Seedling)', () {
        final xp = service.xpRequiredForNextStage(0);
        expect(
            xp, equals(AppConstants.sproutStageThreshold - 0)); // 20 - 0 = 20
      });

      test('returns correct XP for stage 1 (Seedling) with XP below threshold', () {
        final xp = service.xpRequiredForNextStage(10);
        // Estimated level: (10/100).floor() + 1 = 1, so stage 1
        // XP needed: 20 - 10 = 10
        expect(xp, equals(AppConstants.sproutStageThreshold - 10));
      });

      test('handles XP values correctly for different stages', () {
        // Test with XP that clearly maps to stage 1
        final xp1 = service.xpRequiredForNextStage(5);
        expect(xp1, equals(AppConstants.sproutStageThreshold - 5)); // 20 - 5 = 15

        // Test with XP that maps to stage 2 (level 3-5)
        // Level 3 requires ~200 XP, so use XP around 200-400 range
        final xp2 = service.xpRequiredForNextStage(300);
        // Estimated level: (300/100).floor() + 1 = 4, so stage 2
        // The method will calculate based on stage 2 threshold
        expect(xp2, isA<int>());
      });

      test('handles edge cases', () {
        expect(service.xpRequiredForNextStage(-10), greaterThan(0));
      });
    });

    group('shouldEvolve', () {
      test('returns true when stage increases', () {
        // XP to level: (xp / 100).floor() + 1
        // Level 1 (stage 1): 0-99 XP
        // Level 2 (stage 1): 100-199 XP  
        // Level 3 (stage 2): 200-299 XP
        // Level 6 (stage 3): 500-599 XP
        // Level 11 (stage 4): 1000-1099 XP
        expect(service.shouldEvolve(300, 50), isTrue); // Level 4 (stage 2) vs Level 1 (stage 1)
        expect(service.shouldEvolve(600, 300), isTrue); // Level 7 (stage 3) vs Level 4 (stage 2)
        expect(service.shouldEvolve(1100, 600), isTrue); // Level 12 (stage 4) vs Level 7 (stage 3)
      });

      test('returns false when stage stays same', () {
        // Both estimate to level 1 (stage 1)
        expect(service.shouldEvolve(15, 10), isFalse);
        // Both estimate to level 2 (stage 1)
        expect(service.shouldEvolve(150, 100), isFalse);
      });

      test('returns false when XP decreases (should not happen)', () {
        expect(service.shouldEvolve(10, 20), isFalse);
      });

      test('returns false when at same stage boundary', () {
        // Both estimate to level 1 (stage 1)
        expect(service.shouldEvolve(20, 19), isFalse);
      });
    });

    group('calculatePlantHealth', () {
      test('returns 0 when lastActivityDate is null', () {
        expect(service.calculatePlantHealth(null, 100), equals(0));
      });

      test('returns 100 when activity was today', () {
        final today = DateTime.now();
        expect(service.calculatePlantHealth(today, 50), equals(100));
      });

      test('decreases health by 5% per day', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final health = service.calculatePlantHealth(yesterday, 100);
        expect(health, equals(95)); // 100 - (1 * 5) = 95
      });

      test('decreases health correctly for multiple days', () {
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
        final health = service.calculatePlantHealth(threeDaysAgo, 100);
        expect(health, equals(85)); // 100 - (3 * 5) = 85
      });

      test('health cannot go below 0', () {
        final twentyDaysAgo = DateTime.now().subtract(const Duration(days: 20));
        final health = service.calculatePlantHealth(twentyDaysAgo, 100);
        expect(health, equals(0)); // 100 - (20 * 5) = 0, clamped to 0
      });

      test('health cannot exceed 100', () {
        final today = DateTime.now();
        final health = service.calculatePlantHealth(today, 150);
        expect(health, equals(100)); // Clamped to 100
      });

      test('handles partial days correctly', () {
        // 12 hours ago is still 0 days difference (uses inDays)
        final yesterday = DateTime.now().subtract(const Duration(hours: 12));
        final health = service.calculatePlantHealth(yesterday, 100);
        // inDays returns 0 for less than 24 hours, so health stays at 100
        expect(health, equals(100));
        
        // Test with 25 hours ago (1 full day)
        final dayAgo = DateTime.now().subtract(const Duration(hours: 25));
        final health2 = service.calculatePlantHealth(dayAgo, 100);
        expect(health2, equals(95)); // 100 - (1 * 5) = 95
      });
    });

    group('getPlantMood', () {
      test('returns excellent for high health and long streak', () {
        final mood = service.getPlantMood(85, 10);
        expect(mood, equals(PlantMood.excellent));
      });

      test('returns happy for good health and decent streak', () {
        final mood = service.getPlantMood(70, 5);
        expect(mood, equals(PlantMood.happy));
      });

      test('returns neutral for moderate health', () {
        final mood = service.getPlantMood(50, 1);
        expect(mood, equals(PlantMood.neutral));
      });

      test('returns sad for low health', () {
        final mood = service.getPlantMood(30, 0);
        expect(mood, equals(PlantMood.sad));
      });

      test('returns wilting for very low health', () {
        final mood = service.getPlantMood(15, 0);
        expect(mood, equals(PlantMood.wilting));
      });

      test('handles edge cases', () {
        // 80 health + 6 streak: health >= 80 but streak < 7, so happy
        expect(service.getPlantMood(80, 6), equals(PlantMood.happy));
        // 80 health + 7 streak: excellent
        expect(service.getPlantMood(80, 7), equals(PlantMood.excellent));
        // 60 health + 2 streak: health >= 60 but streak < 3, so neutral
        expect(service.getPlantMood(60, 2), equals(PlantMood.neutral));
        expect(service.getPlantMood(40, 0), equals(PlantMood.neutral));
        expect(service.getPlantMood(20, 0), equals(PlantMood.sad));
        expect(service.getPlantMood(0, 0), equals(PlantMood.wilting));
      });
    });

    group('getGrowthProgress', () {
      test('returns 0.0 for stage start', () {
        final progress = service.getGrowthProgress(
          AppConstants.seedStageThreshold,
          1,
        );
        expect(progress, equals(0.0));
      });

      test('returns 1.0 for stage end', () {
        final progress = service.getGrowthProgress(
          AppConstants.sproutStageThreshold,
          1,
        );
        expect(progress, equals(1.0));
      });

      test('returns 0.5 for middle of stage', () {
        final progress = service.getGrowthProgress(
          AppConstants.sproutStageThreshold ~/ 2,
          1,
        );
        expect(progress, closeTo(0.5, 0.1));
      });

      test('returns 1.0 for max stage (stage 5)', () {
        final progress = service.getGrowthProgress(1000, 5);
        expect(progress, equals(1.0));
      });

      test('clamps progress between 0.0 and 1.0', () {
        final negativeProgress = service.getGrowthProgress(-10, 1);
        final overProgress = service.getGrowthProgress(1000, 1);

        expect(negativeProgress, greaterThanOrEqualTo(0.0));
        expect(negativeProgress, lessThanOrEqualTo(1.0));
        expect(overProgress, lessThanOrEqualTo(1.0));
      });

      test('handles invalid stage gracefully', () {
        final progress = service.getGrowthProgress(50, 99);
        expect(progress, greaterThanOrEqualTo(0.0));
        expect(progress, lessThanOrEqualTo(1.0));
      });
    });

    group('getMotivationalMessage', () {
      test('returns urgent message for low health', () {
        final message = service.getMotivationalMessage(15, 0, 1);
        expect(message, contains('needs care'));
      });

      test('returns encouraging message for moderate health', () {
        final message = service.getMotivationalMessage(30, 0, 1);
        expect(message, contains('Keep going'));
      });

      test('returns streak message for long streak', () {
        final message = service.getMotivationalMessage(80, 10, 2);
        expect(message, contains('streak'));
      });

      test('returns progress message for good streak', () {
        final message = service.getMotivationalMessage(70, 5, 2);
        expect(message, contains('progress'));
      });

      test('returns tree message for advanced stage', () {
        final message = service.getMotivationalMessage(60, 1, 4);
        expect(message, contains('tree'));
      });

      test('returns default message for normal state', () {
        final message = service.getMotivationalMessage(50, 1, 2);
        expect(message, isNotEmpty);
        expect(message, contains('grow'));
      });
    });

    group('PlantMood extension', () {
      test('returns correct emoji for each mood', () {
        expect(PlantMood.excellent.emoji, equals('🌟'));
        expect(PlantMood.happy.emoji, equals('😊'));
        expect(PlantMood.neutral.emoji, equals('🌱'));
        expect(PlantMood.sad.emoji, equals('😔'));
        expect(PlantMood.wilting.emoji, equals('🥀'));
      });

      test('returns correct description for each mood', () {
        expect(PlantMood.excellent.description, equals('Thriving'));
        expect(PlantMood.happy.description, equals('Happy'));
        expect(PlantMood.neutral.description, equals('Growing'));
        expect(PlantMood.sad.description, equals('Needs Care'));
        expect(PlantMood.wilting.description, equals('Wilting'));
      });
    });
  });
}
