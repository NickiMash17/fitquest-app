import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement_model.freezed.dart';
part 'achievement_model.g.dart';

/// Achievement type enum
enum AchievementType {
  streak,
  xp,
  activities,
  level,
  special,
}

/// Achievement rarity
enum AchievementRarity {
  common,
  rare,
  epic,
  legendary,
}

/// Achievement model
@freezed
class AchievementModel with _$AchievementModel {
  const factory AchievementModel({
    required String id,
    required String title,
    required String description,
    required AchievementType type,
    required AchievementRarity rarity,
    required int targetValue,
    required String icon,
    @Default(0) int currentProgress,
    @Default(false) bool unlocked,
    DateTime? unlockedAt,
    @Default(0) int xpReward,
  }) = _AchievementModel;

  factory AchievementModel.fromJson(Map<String, dynamic> json) =>
      _$AchievementModelFromJson(json);
}

