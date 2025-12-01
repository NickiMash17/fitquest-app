import 'package:equatable/equatable.dart';
import 'package:fitquest/shared/models/user_model.dart';
import 'package:fitquest/shared/models/challenge_model.dart';
import 'package:fitquest/shared/models/activity_model.dart';

/// Home states
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Loading state
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Loaded state
class HomeLoaded extends HomeState {
  final UserModel user;
  final ChallengeModel? dailyChallenge;
  final List<ActivityModel> todayActivities;
  final int todayXp;

  const HomeLoaded({
    required this.user,
    this.dailyChallenge,
    required this.todayActivities,
    required this.todayXp,
  });

  @override
  List<Object?> get props => [user, dailyChallenge, todayActivities, todayXp];
}

/// Error state
class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}

