import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_model.freezed.dart';
part 'goal_model.g.dart';

/// Goal type enum
enum GoalType {
  daily,
  weekly,
  monthly,
  custom,
}

/// Goal status
enum GoalStatus {
  active,
  completed,
  failed,
  paused,
}

/// Goal model
@freezed
class GoalModel with _$GoalModel {
  const factory GoalModel({
    required String id,
    required String userId,
    required String title,
    required String description,
    required GoalType type,
    required GoalStatus status,
    required int targetValue,
    required String targetUnit, // e.g., "minutes", "activities", "XP"
    @Default(0) int currentProgress,
    required DateTime startDate,
    required DateTime endDate,
    DateTime? completedAt,
    @Default(0) int xpReward,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _GoalModel;

  factory GoalModel.fromJson(Map<String, dynamic> json) =>
      _$GoalModelFromJson(json);
}

