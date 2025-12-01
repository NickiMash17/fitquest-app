import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge_model.freezed.dart';
part 'challenge_model.g.dart';

/// Challenge model representing a daily or weekly challenge
@freezed
class ChallengeModel with _$ChallengeModel {
  const factory ChallengeModel({
    required String id,
    required String title,
    required String description,
    required ChallengeType type,
    required DateTime startDate,
    required DateTime endDate,
    required int targetValue,
    required String targetUnit,
    required int xpReward,
    String? badgeId,
    @Default(0) int currentProgress,
    @Default(false) bool completed,
    DateTime? completedAt,
  }) = _ChallengeModel;

  factory ChallengeModel.fromJson(Map<String, dynamic> json) =>
      _$ChallengeModelFromJson(json);
}

/// Challenge type enum
enum ChallengeType {
  daily,
  weekly,
  monthly,
  special,
}

