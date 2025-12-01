import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_model.freezed.dart';
part 'activity_model.g.dart';

/// Activity type enum
enum ActivityType {
  exercise,
  meditation,
  hydration,
  sleep,
}

/// Activity model representing a logged activity
@freezed
class ActivityModel with _$ActivityModel {
  const factory ActivityModel({
    required String id,
    required String userId,
    required ActivityType type,
    required DateTime date,
    required int duration, // in minutes
    String? notes,
    int? calories,
    double? distance, // in km
    int? glasses, // for hydration
    int? hours, // for sleep
    @Default(0) int xpEarned,
    @Default(0) int pointsEarned,
    DateTime? createdAt,
  }) = _ActivityModel;

  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelFromJson(json);
}

