// lib/features/home/data/models/wellness_data.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wellness_data.freezed.dart';
part 'wellness_data.g.dart';

/// Wellness data model for tracking daily wellness metrics
@freezed
class WellnessData with _$WellnessData {
  const factory WellnessData({
    required DateTime date,
    @Default(0) int workoutsCompleted,
    @Default(0) double caloriesBurned,
    @Default(0) int meditationMinutes,
    @Default(0) int waterIntakeMl,
    @Default(0.0) double sleepHours,
    @Default(0.0) double sleepQuality,
    @Default(0) int totalXP,
    @Default(false) bool exerciseCompleted,
    @Default(false) bool meditationCompleted,
    @Default(false) bool hydrationCompleted,
    @Default(false) bool sleepCompleted,
    @Default(0.0) double exerciseConsistency,
    @Default(0.0) double meditationRegularity,
    @Default(0.0) double hydrationLevel,
  }) = _WellnessData;

  factory WellnessData.fromJson(Map<String, dynamic> json) =>
      _$WellnessDataFromJson(json);

  factory WellnessData.initial({required DateTime date}) => WellnessData(
        date: date,
      );
}
