// test/services/xp_calculator_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fitquest/shared/services/xp_calculator_service.dart';
import 'package:fitquest/shared/models/activity_model.dart';
import 'package:fitquest/core/constants/app_constants.dart';

void main() {
  group('XpCalculatorService', () {
    late XpCalculatorService service;

    setUp(() {
      service = XpCalculatorService();
    });

    group('calculateXp', () {
      test('calculates XP correctly for exercise activity', () {
        final activity = ActivityModel(
          id: '1',
          userId: 'user1',
          type: ActivityType.exercise,
          date: DateTime.now(),
          duration: 30, // 30 minutes
        );

        final xp = service.calculateXp(activity);
        expect(
            xp, equals(30 * AppConstants.exerciseXpPerMinute)); // 30 * 5 = 150
      });

      test('calculates XP correctly for meditation activity', () {
        final activity = ActivityModel(
          id: '2',
          userId: 'user1',
          type: ActivityType.meditation,
          date: DateTime.now(),
          duration: 20, // 20 minutes
        );

        final xp = service.calculateXp(activity);
        expect(xp,
            equals(20 * AppConstants.meditationXpPerMinute)); // 20 * 7 = 140
      });

      test('calculates XP correctly for hydration activity', () {
        final activity = ActivityModel(
          id: '3',
          userId: 'user1',
          type: ActivityType.hydration,
          date: DateTime.now(),
          duration: 0,
          glasses: 4, // 4 glasses
        );

        final xp = service.calculateXp(activity);
        expect(xp, equals(4 * AppConstants.hydrationXpPerGlass)); // 4 * 15 = 60
      });

      test('calculates XP correctly for sleep activity', () {
        final activity = ActivityModel(
          id: '4',
          userId: 'user1',
          type: ActivityType.sleep,
          date: DateTime.now(),
          duration: 0,
          hours: 8, // 8 hours
        );

        final xp = service.calculateXp(activity);
        expect(xp, equals(8 * AppConstants.sleepXpPerHour)); // 8 * 10 = 80
      });

      test('returns 0 XP for zero duration/amount', () {
        final exercise = ActivityModel(
          id: '5',
          userId: 'user1',
          type: ActivityType.exercise,
          date: DateTime.now(),
          duration: 0,
        );

        final hydration = ActivityModel(
          id: '6',
          userId: 'user1',
          type: ActivityType.hydration,
          date: DateTime.now(),
          duration: 0,
          glasses: 0,
        );

        expect(service.calculateXp(exercise), equals(0));
        expect(service.calculateXp(hydration), equals(0));
      });
    });

    group('calculatePoints', () {
      test('calculates points correctly for exercise activity', () {
        final activity = ActivityModel(
          id: '1',
          userId: 'user1',
          type: ActivityType.exercise,
          date: DateTime.now(),
          duration: 30,
        );

        final points = service.calculatePoints(activity);
        expect(points,
            equals(30 * AppConstants.exercisePointsPerMinute)); // 30 * 2 = 60
      });

      test('calculates points correctly for meditation activity', () {
        final activity = ActivityModel(
          id: '2',
          userId: 'user1',
          type: ActivityType.meditation,
          date: DateTime.now(),
          duration: 20,
        );

        final points = service.calculatePoints(activity);
        expect(points,
            equals(20 * AppConstants.meditationPointsPerMinute)); // 20 * 3 = 60
      });

      test('calculates points correctly for hydration activity', () {
        final activity = ActivityModel(
          id: '3',
          userId: 'user1',
          type: ActivityType.hydration,
          date: DateTime.now(),
          duration: 0,
          glasses: 4,
        );

        final points = service.calculatePoints(activity);
        expect(points,
            equals(4 * AppConstants.hydrationPointsPerGlass)); // 4 * 10 = 40
      });

      test('calculates points correctly for sleep activity', () {
        final activity = ActivityModel(
          id: '4',
          userId: 'user1',
          type: ActivityType.sleep,
          date: DateTime.now(),
          duration: 0,
          hours: 8,
        );

        final points = service.calculatePoints(activity);
        expect(
            points, equals(8 * AppConstants.sleepPointsPerHour)); // 8 * 5 = 40
      });
    });

    group('calculateLevel', () {
      test('returns level 1 for 0 XP', () {
        expect(service.calculateLevel(0), equals(1));
      });

      test('returns level 1 for XP less than 100', () {
        expect(service.calculateLevel(50), equals(1));
        expect(service.calculateLevel(99), equals(1));
      });

      test('returns correct level for various XP amounts', () {
        // Level formula: level = sqrt(totalXp / 100) + 1
        expect(service.calculateLevel(100), equals(2)); // sqrt(1) + 1 = 2
        expect(service.calculateLevel(400), equals(3)); // sqrt(4) + 1 = 3
        expect(service.calculateLevel(900), equals(4)); // sqrt(9) + 1 = 4
        expect(service.calculateLevel(1600), equals(5)); // sqrt(16) + 1 = 5
      });

      test('handles large XP values correctly', () {
        expect(service.calculateLevel(10000), greaterThan(10));
        expect(service.calculateLevel(100000), greaterThan(30));
      });
    });

    group('xpRequiredForNextLevel', () {
      test('returns 100 XP for level 1', () {
        expect(service.xpRequiredForNextLevel(1), equals(100));
      });

      test('returns correct XP for level 2', () {
        // Formula: 100 * (1.5 ^ (level-1))
        // Level 2: 100 * (1.5 ^ 1) = 150
        expect(service.xpRequiredForNextLevel(2), equals(150));
      });

      test('returns correct XP for level 3', () {
        // Level 3: 100 * (1.5 ^ 2) = 225
        expect(service.xpRequiredForNextLevel(3), equals(225));
      });

      test('returns increasing XP for higher levels', () {
        final level2 = service.xpRequiredForNextLevel(2);
        final level3 = service.xpRequiredForNextLevel(3);
        final level4 = service.xpRequiredForNextLevel(4);
        final level5 = service.xpRequiredForNextLevel(5);

        expect(level3, greaterThan(level2));
        expect(level4, greaterThan(level3));
        expect(level5, greaterThan(level4));
      });

      test('handles very high levels', () {
        final xp = service.xpRequiredForNextLevel(50);
        expect(xp, greaterThan(1000000)); // Should be a very large number
      });
    });

    group('totalXpForLevel', () {
      test('returns 0 for level 1', () {
        expect(service.totalXpForLevel(1), equals(0));
      });

      test('returns correct total XP for level 2', () {
        // Level 2 requires 100 XP from level 1
        expect(service.totalXpForLevel(2), equals(100));
      });

      test('returns correct total XP for level 3', () {
        // Level 3 requires 100 (level 1->2) + 150 (level 2->3) = 250
        expect(service.totalXpForLevel(3), equals(250));
      });

      test('returns cumulative XP correctly', () {
        final level4 = service.totalXpForLevel(4);
        final level5 = service.totalXpForLevel(5);

        expect(level5, greaterThan(level4));
      });
    });

    group('calculateEvolutionStage', () {
      test('returns stage 1 (Seedling) for levels 1-2', () {
        expect(service.calculateEvolutionStage(1), equals(1));
        expect(service.calculateEvolutionStage(2), equals(1));
      });

      test('returns stage 2 (Sprout) for levels 3-5', () {
        expect(service.calculateEvolutionStage(3), equals(2));
        expect(service.calculateEvolutionStage(5), equals(2));
      });

      test('returns stage 3 (Sapling) for levels 6-10', () {
        expect(service.calculateEvolutionStage(6), equals(3));
        expect(service.calculateEvolutionStage(10), equals(3));
      });

      test('returns stage 4 (Young Tree) for levels 11-20', () {
        expect(service.calculateEvolutionStage(11), equals(4));
        expect(service.calculateEvolutionStage(20), equals(4));
      });

      test('returns stage 5 (Mature Tree) for levels 21-35', () {
        expect(service.calculateEvolutionStage(21), equals(5));
        expect(service.calculateEvolutionStage(35), equals(5));
      });

      test('returns stage 6 (Majestic Tree) for level 36+', () {
        expect(service.calculateEvolutionStage(36), equals(6));
        expect(service.calculateEvolutionStage(50), equals(6));
        expect(service.calculateEvolutionStage(100), equals(6));
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

      test('returns default name for invalid stage', () {
        expect(service.getEvolutionStageName(0), equals('Seedling'));
        expect(service.getEvolutionStageName(7), equals('Seedling'));
        expect(service.getEvolutionStageName(-1), equals('Seedling'));
      });
    });

    group('SqrtExtension', () {
      test('calculates square root correctly', () {
        expect(4.sqrt(), closeTo(2.0, 0.0001));
        expect(9.sqrt(), closeTo(3.0, 0.0001));
        expect(16.sqrt(), closeTo(4.0, 0.0001));
        expect(25.sqrt(), closeTo(5.0, 0.0001));
      });

      test('returns 0 for zero or negative numbers', () {
        expect(0.sqrt(), equals(0));
        expect((-1).sqrt(), equals(0));
      });

      test('handles decimal results', () {
        expect(2.sqrt(), closeTo(1.4142, 0.0001));
        expect(3.sqrt(), closeTo(1.7320, 0.0001));
      });
    });
  });
}
