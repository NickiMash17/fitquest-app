import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User model representing app user
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
    @Default(0) int totalXp,
    @Default(0) int totalPoints,
    @Default(0) int currentLevel,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    DateTime? lastActivityDate,
    @Default(1) int plantEvolutionStage,
    @Default(0) int plantCurrentXp,
    @Default(100) int plantHealth,
    String? plantName,
    @Default([]) List<String> unlockedBadges,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

