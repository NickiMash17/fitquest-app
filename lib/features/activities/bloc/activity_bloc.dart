import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:fitquest/features/activities/bloc/activity_event.dart';
import 'package:fitquest/features/activities/bloc/activity_state.dart';
import 'package:fitquest/shared/repositories/activity_repository.dart';
import 'package:fitquest/shared/repositories/user_repository.dart';
import 'package:fitquest/shared/services/xp_calculator_service.dart';
import 'package:fitquest/shared/models/activity_model.dart';
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
      _logger.e(
        'Unexpected error loading activities',
        error: e,
        stackTrace: stackTrace,
      );
      emit(const ActivityError(message: 'Failed to load activities'));
    }
  }

  Future<void> _onActivityCreateRequested(
    ActivityCreateRequested event,
    Emitter<ActivityState> emit,
  ) async {
    _logger.i('=== ACTIVITY CREATE REQUESTED ===');
    _logger.i(
        'Event received: ${event.activity.type}, duration: ${event.activity.duration}');

    // Emit loading state first to ensure state change
    _logger.i('Emitting ActivityLoading state');
    emit(const ActivityLoading());

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

      _logger.i('Creating activity: ${activity.id} for user: $userId');
      _logger.i(
          'Activity details: type=${activity.type}, duration=${activity.duration}, date=${activity.date}');

      // Save activity
      String savedId;
      try {
        savedId = await _activityRepository.createActivity(activity);
        _logger.i(
            'Activity saved to Firestore with ID: $savedId (original: ${activity.id})');
      } catch (e, stackTrace) {
        _logger.e('CRITICAL: Failed to save activity to Firestore',
            error: e, stackTrace: stackTrace);
        emit(
            ActivityError(message: 'Failed to save activity: ${e.toString()}'));
        return;
      }

      // Update user XP and points
      try {
        await _userRepository.addXp(userId, xp);
        _logger.i('User XP updated');
      } catch (e, stackTrace) {
        _logger.w('Failed to update user XP (non-critical): $e',
            error: e, stackTrace: stackTrace);
        // Continue even if XP update fails
      }

      // Update streak
      try {
        await _updateStreak(userId);
        _logger.i('Streak updated');
      } catch (e, stackTrace) {
        _logger.w('Failed to update streak (non-critical): $e',
            error: e, stackTrace: stackTrace);
        // Continue even if streak update fails
      }

      _logger.i('Activity created successfully: ${activity.id}');
      _logger.i('Firestore document ID: $savedId');

      // First, verify the document exists by reading it directly
      try {
        final verifiedActivity = await _activityRepository.getActivityById(savedId);
        if (verifiedActivity != null) {
          _logger.i('Verified: Activity document exists and can be loaded');
          _logger.i('Verified activity userId: ${verifiedActivity.userId}, expected: $userId');
          _logger.i('Verified activity date: ${verifiedActivity.date}');
        } else {
          _logger.e('ERROR: Activity document exists but cannot be loaded!');
        }
      } catch (e, stackTrace) {
        _logger.e('Error verifying activity document', error: e, stackTrace: stackTrace);
      }

      // Wait a moment for Firestore to be ready, then reload
      // Use a longer delay to ensure Firestore has indexed the new document
      await Future.delayed(const Duration(milliseconds: 1500));

      // Try to reload activities multiple times if needed (with exponential backoff)
      List<ActivityModel> activities = [];
      bool foundActivity = false;

      for (int attempt = 0; attempt < 3; attempt++) {
        try {
          _logger.i(
              'Reloading activities after creation (attempt ${attempt + 1}/3)...');
          activities = await _activityRepository.getActivities(userId);
          _logger.i('Reloaded ${activities.length} activities after creation');
          _logger
              .i('Looking for activity with ID: $savedId (Firestore doc ID)');
          _logger.i(
              'Loaded activity IDs: ${activities.map((a) => a.id).toList()}');

          // Verify the new activity is in the list
          // Note: savedId is the Firestore document ID, which should match doc.id when reloading
          foundActivity = activities.any((a) => a.id == savedId);

          if (!foundActivity) {
            // Also check by matching other fields as fallback
            foundActivity = activities.any((a) =>
                a.userId == userId &&
                a.type == activity.type &&
                a.date.year == activity.date.year &&
                a.date.month == activity.date.month &&
                a.date.day == activity.date.day &&
                a.duration == activity.duration);
            if (foundActivity) {
              _logger.i('Found activity by matching fields (not by ID)');
            }
          }

          _logger.i('New activity found in reloaded list: $foundActivity');

          if (foundActivity) {
            _logger.i('Activity found on attempt ${attempt + 1}');
            break; // Found it, exit loop
          }

          if (attempt < 2) {
            // Wait a bit longer before next attempt
            final delayMs = 800 * (attempt + 1);
            _logger
                .i('Activity not found, waiting ${delayMs}ms before retry...');
            await Future.delayed(Duration(milliseconds: delayMs));
          }
        } catch (e, stackTrace) {
          _logger.e('Error reloading activities (attempt ${attempt + 1})',
              error: e, stackTrace: stackTrace);
          if (attempt == 2) {
            // Last attempt failed, but still emit what we have
            break;
          }
          await Future.delayed(Duration(milliseconds: 800 * (attempt + 1)));
        }
      }

      // If still not found, try to get it directly and add it to the list
      if (!foundActivity) {
        _logger.w(
            'WARNING: New activity not found in reloaded list after 3 attempts!');
        _logger
            .w('Activity UUID: ${activity.id}, Saved Firestore ID: $savedId');
        _logger
            .w('Activity userId: ${activity.userId}, Current userId: $userId');
        _logger.w(
            'Activity type: ${activity.type.name}, duration: ${activity.duration}');
        _logger.w('Activity date: ${activity.date}');
        _logger.w('Loaded ${activities.length} activities');
        if (activities.isNotEmpty) {
          _logger.w(
              'First loaded activity: userId=${activities.first.userId}, type=${activities.first.type.name}');
        }
        
        // Try to get the activity directly and add it to the list
        try {
          final directActivity = await _activityRepository.getActivityById(savedId);
          if (directActivity != null) {
            _logger.i('Found activity by direct lookup, adding to list');
            // Check if it's not already in the list (by ID)
            if (!activities.any((a) => a.id == savedId)) {
              activities.insert(0, directActivity); // Add at the beginning
              _logger.i('Added activity to list directly. New count: ${activities.length}');
              foundActivity = true;
            }
          } else {
            _logger.e('Activity cannot be loaded even by direct lookup!');
          }
        } catch (e, stackTrace) {
          _logger.e('Error loading activity directly', error: e, stackTrace: stackTrace);
        }
      }

      // Always emit ActivityLoaded to trigger listener
      emit(ActivityLoaded(activities: activities));
      _logger.i('Emitted ActivityLoaded with ${activities.length} activities');
    } catch (e, stackTrace) {
      _logger.e('Error creating activity', error: e, stackTrace: stackTrace);
      emit(
          ActivityError(message: 'Failed to create activity: ${e.toString()}'));
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
