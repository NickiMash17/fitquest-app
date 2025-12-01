import 'package:equatable/equatable.dart';
import 'package:fitquest/shared/models/activity_model.dart';

/// Activity events
abstract class ActivityEvent extends Equatable {
  const ActivityEvent();

  @override
  List<Object?> get props => [];
}

/// Load activities
class ActivitiesLoadRequested extends ActivityEvent {
  const ActivitiesLoadRequested();
}

/// Create activity
class ActivityCreateRequested extends ActivityEvent {
  final ActivityModel activity;

  const ActivityCreateRequested({required this.activity});

  @override
  List<Object?> get props => [activity];
}

/// Update activity
class ActivityUpdateRequested extends ActivityEvent {
  final ActivityModel activity;

  const ActivityUpdateRequested({required this.activity});

  @override
  List<Object?> get props => [activity];
}

/// Delete activity
class ActivityDeleteRequested extends ActivityEvent {
  final String activityId;

  const ActivityDeleteRequested({required this.activityId});

  @override
  List<Object?> get props => [activityId];
}

