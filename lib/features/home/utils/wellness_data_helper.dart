// lib/features/home/utils/wellness_data_helper.dart
import 'package:fitquest/features/home/data/models/wellness_data.dart';
import 'package:fitquest/shared/models/user_model.dart';
import 'package:fitquest/shared/models/activity_model.dart';

/// Helper to convert existing app data to WellnessData
class WellnessDataHelper {
  /// Calculate wellness data from user and activities
  static WellnessData calculateWellnessData({
    required UserModel user,
    required List<ActivityModel> todayActivities,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Calculate exercise metrics
    final exerciseActivities =
        todayActivities.where((a) => a.type == ActivityType.exercise).toList();
    final exerciseMinutes =
        exerciseActivities.fold<int>(0, (sum, a) => sum + a.duration);
    final exerciseCompleted = exerciseMinutes >= 30; // 30 min goal
    final exerciseConsistency = (exerciseMinutes / 30.0).clamp(0.0, 1.0);

    // Calculate meditation metrics
    final meditationActivities = todayActivities
        .where((a) => a.type == ActivityType.meditation)
        .toList();
    final meditationMinutes =
        meditationActivities.fold<int>(0, (sum, a) => sum + a.duration);
    final meditationCompleted = meditationMinutes >= 10; // 10 min goal
    final meditationRegularity = (meditationMinutes / 10.0).clamp(0.0, 1.0);

    // Calculate hydration metrics
    final hydrationActivities =
        todayActivities.where((a) => a.type == ActivityType.hydration).toList();
    final waterGlasses =
        hydrationActivities.fold<int>(0, (sum, a) => sum + (a.glasses ?? 0));
    final waterMl = waterGlasses * 250; // Assume 250ml per glass
    final hydrationCompleted = waterGlasses >= 8; // 8 glasses goal
    final hydrationLevel = (waterGlasses / 8.0).clamp(0.0, 1.0);

    // Calculate sleep metrics (simplified - would need actual sleep data)
    final sleepActivities =
        todayActivities.where((a) => a.type == ActivityType.sleep).toList();
    final sleepHours =
        sleepActivities.fold<double>(0.0, (sum, a) => sum + (a.hours ?? 0.0));
    final sleepCompleted = sleepHours >= 7.0; // 7 hours goal
    final sleepQuality =
        sleepHours >= 7.0 ? 0.9 : (sleepHours / 7.0).clamp(0.0, 1.0);

    // Calculate calories (from exercise)
    final caloriesBurned = exerciseActivities.fold<double>(
        0.0, (sum, a) => sum + (a.calories ?? 0.0));

    return WellnessData(
      date: today,
      workoutsCompleted: exerciseActivities.length,
      caloriesBurned: caloriesBurned,
      meditationMinutes: meditationMinutes,
      waterIntakeMl: waterMl,
      sleepHours: sleepHours,
      sleepQuality: sleepQuality,
      totalXP: user.totalXp,
      exerciseCompleted: exerciseCompleted,
      meditationCompleted: meditationCompleted,
      hydrationCompleted: hydrationCompleted,
      sleepCompleted: sleepCompleted,
      exerciseConsistency: exerciseConsistency,
      meditationRegularity: meditationRegularity,
      hydrationLevel: hydrationLevel,
    );
  }

  /// Calculate progress values for wellness ring (0.0 to 1.0)
  static Map<String, double> calculateWellnessProgress(WellnessData data) {
    return {
      'exercise': data.exerciseConsistency,
      'meditation': data.meditationRegularity,
      'hydration': data.hydrationLevel,
      'sleep': data.sleepQuality,
    };
  }
}
