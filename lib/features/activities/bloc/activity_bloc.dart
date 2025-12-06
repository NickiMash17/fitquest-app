import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:fitquest/features/activities/bloc/activity_event.dart';
import 'package:fitquest/features/activities/bloc/activity_state.dart';
import 'package:fitquest/shared/repositories/activity_repository.dart';
import 'package:fitquest/shared/repositories/user_repository.dart';
import 'package:fitquest/shared/services/xp_calculator_service.dart';
import 'package:uuid/uuid.dart';

/// Activity BLoC
@injectable
class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final ActivityRepository _activityRepository;
  final UserRepository _userRepository;
  final XpCalculatorService _xpCalculator;
  final FirebaseAuth _auth;
  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();

  ActivityBloc(
    this._activityRepository,
    this._userRepository,
    this._xpCalculator,
    this._auth,
  ) : super(const ActivityInitial()) {
    on<ActivitiesLoadRequested>(_onActivitiesLoadRequested);
    on<ActivityCreateRequested>(_onActivityCreateRequested);
    on<ActivityUpdateRequested>(_onActivityUpdateRequested);
    on<ActivityDeleteRequested>(_onActivityDeleteRequested);
  }

  Future<void> _onActivitiesLoadRequested(
    ActivitiesLoadRequested event,
    Emitter<ActivityState> emit,
  ) async {
    emit(const ActivityLoading());
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        emit(const ActivityError(message: 'User not authenticated'));
        return;
      }

      // Load activities - handle errors gracefully
      try {
        final activities = await _activityRepository.getActivities(userId);
        _logger.d('Loaded ${activities.length} activities');
        emit(ActivityLoaded(activities: activities));
      } on FirebaseException catch (e) {
        // Handle Firestore index errors gracefully
        if (e.code == 'failed-precondition') {
          _logger.w('Firestore index not created yet. Showing empty list.');
          emit(const ActivityLoaded(activities: []));
        } else {
          _logger.e('Error loading activities', error: e);
          emit(const ActivityError(message: 'Failed to load activities'));
        }
      } catch (e, stackTrace) {
        _logger.e('Error loading activities', error: e, stackTrace: stackTrace);
        // On any other error, show empty list instead of error state
        _logger.w('Showing empty list due to error');
        emit(const ActivityLoaded(activities: []));
      }
    } catch (e, stackTrace) {
      _logger.e('Unexpected error loading activities',
          error: e, stackTrace: stackTrace,);
      emit(const ActivityError(message: 'Failed to load activities'));
    }
  }

  Future<void> _onActivityCreateRequested(
    ActivityCreateRequested event,
    Emitter<ActivityState> emit,
  ) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        emit(const ActivityError(message: 'User not authenticated'));
        return;
      }

      // Calculate XP and points
      final xp = _xpCalculator.calculateXp(event.activity);
      final points = _xpCalculator.calculatePoints(event.activity);

      // Create activity with calculated values
      final activity = event.activity.copyWith(
        id: _uuid.v4(),
        userId: userId,
        xpEarned: xp,
        pointsEarned: points,
        createdAt: DateTime.now(),
      );

      // Save activity
      await _activityRepository.createActivity(activity);

      // Update user XP and points
      await _userRepository.addXp(userId, xp);

      // Update streak
      await _updateStreak(userId);

      _logger.i('Activity created: ${activity.id}');
    } catch (e, stackTrace) {
      _logger.e('Error creating activity', error: e, stackTrace: stackTrace);
      emit(const ActivityError(message: 'Failed to create activity'));
    }
  }

  Future<void> _onActivityUpdateRequested(
    ActivityUpdateRequested event,
    Emitter<ActivityState> emit,
  ) async {
    try {
      await _activityRepository.updateActivity(event.activity);
      _logger.i('Activity updated: ${event.activity.id}');
    } catch (e, stackTrace) {
      _logger.e('Error updating activity', error: e, stackTrace: stackTrace);
      emit(const ActivityError(message: 'Failed to update activity'));
    }
  }

  Future<void> _onActivityDeleteRequested(
    ActivityDeleteRequested event,
    Emitter<ActivityState> emit,
  ) async {
    try {
      await _activityRepository.deleteActivity(event.activityId);
      _logger.i('Activity deleted: ${event.activityId}');
    } catch (e, stackTrace) {
      _logger.e('Error deleting activity', error: e, stackTrace: stackTrace);
      emit(const ActivityError(message: 'Failed to delete activity'));
    }
  }

  Future<void> _updateStreak(String userId) async {
    try {
      final user = await _userRepository.getUser(userId);
      if (user == null) return;

      final now = DateTime.now();
      final lastActivityDate = user.lastActivityDate;
      int newStreak = user.currentStreak;

      if (lastActivityDate == null) {
        newStreak = 1;
      } else {
        final daysSince = now.difference(lastActivityDate).inDays;
        if (daysSince == 0) {
          // Same day, keep streak
          return;
        } else if (daysSince == 1) {
          // Consecutive day, increment streak
          newStreak = user.currentStreak + 1;
        } else {
          // Streak broken, reset to 1
          newStreak = 1;
        }
      }

      await _userRepository.updateStreak(userId, newStreak);
    } catch (e, stackTrace) {
      _logger.e('Error updating streak', error: e, stackTrace: stackTrace);
    }
  }
}
