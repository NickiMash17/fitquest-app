import 'package:freezed_annotation/freezed_annotation.dart';

part 'badge_model.freezed.dart';
part 'badge_model.g.dart';

/// Badge model representing an achievement
@freezed
class BadgeModel with _$BadgeModel {
  const factory BadgeModel({
    required String id,
    required String name,
    required String description,
    required String iconUrl,
    required int xpReward,
    required BadgeCategory category,
    required int rarity, // 1-5, 5 being rarest
    DateTime? unlockedAt,
  }) = _BadgeModel;

  factory BadgeModel.fromJson(Map<String, dynamic> json) =>
      _$BadgeModelFromJson(json);
}

/// Badge category enum
enum BadgeCategory {
  streak,
  activity,
  milestone,
  social,
  special,
}

