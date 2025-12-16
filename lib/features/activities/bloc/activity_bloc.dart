import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitquest/features/activities/bloc/activity_event.dart';
import 'package:fitquest/features/activities/bloc/activity_state.dart';
import 'package:fitquest/shared/repositories/activity_repository.dart';
import 'package:fitquest/shared/repositories/user_repository.dart';
import 'package:fitquest/shared/services/xp_calculator_service.dart';
import 'package:fitquest/shared/models/activity_model.dart';
import 'package:fitquest/core/services/error_handler_service.dart';
import 'package:fitquest/core/utils/secure_logger.dart';
import 'package:uuid/uuid.dart';

/// Activity BLoC
@injectable
class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final ActivityRepository _activityRepository;
  final UserRepository _userRepository;
  final XpCalculatorService _xpCalculator;
  final FirebaseAuth _auth;
  final ErrorHandlerService _errorHandler;
  final Uuid _uuid = const Uuid();

  ActivityBloc(
    this._activityRepository,
    this._userRepository,
    this._xpCalculator,
    this._auth,
    this._errorHandler,
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
        SecureLogger.d('Loaded ${activities.length} activities');
        
        // Additional deduplication at bloc level
        final seenIds = <String>{};
        final uniqueActivities = activities.where((activity) {
          if (seenIds.contains(activity.id)) {
            SecureLogger.w('Duplicate activity detected in bloc: ${activity.id}');
            return false;
          }
          seenIds.add(activity.id);
          return true;
        }).toList();
        
        SecureLogger.d('After deduplication: ${uniqueActivities.length} unique activities');
        emit(ActivityLoaded(activities: uniqueActivities));
      } on FirebaseException catch (e) {
        // Handle Firestore index errors gracefully
        if (e.code == 'failed-precondition') {
          SecureLogger.w('Firestore index not created yet. Showing empty list.');
          emit(const ActivityLoaded(activities: []));
        } else {
          SecureLogger.e('Error loading activities', error: e);
          final message = _errorHandler.handleFirebaseException(e);
          emit(ActivityError(message: message));
        }
      } catch (e, stackTrace) {
        SecureLogger.e('Error loading activities',
            error: e, stackTrace: stackTrace,);
        // On any other error, show empty list instead of error state
        SecureLogger.w('Showing empty list due to error');
        emit(const ActivityLoaded(activities: []));
      }
    } catch (e, stackTrace) {
      SecureLogger.e(
        'Unexpected error loading activities',
        error: e,
        stackTrace: stackTrace,
      );
      final message = _errorHandler.handleError(e, type: ErrorType.unknown);
      emit(ActivityError(message: message));
    }
  }

  Future<void> _onActivityCreateRequested(
    ActivityCreateRequested event,
    Emitter<ActivityState> emit,
  ) async {
    SecureLogger.i('=== ACTIVITY CREATE REQUESTED ===');
    SecureLogger.i(
        'Event received: ${event.activity.type}, duration: ${event.activity.duration}',);

    // Emit loading state first to ensure state change
    SecureLogger.i('Emitting ActivityLoading state');
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

      SecureLogger.i('Creating activity: ${activity.id} for user: $userId');
      SecureLogger.i(
          'Activity details: type=${activity.type}, duration=${activity.duration}, date=${activity.date}',);

      // Save activity
      String savedId;
      try {
        savedId = await _activityRepository.createActivity(activity);
        SecureLogger.i(
            'Activity saved to Firestore with ID: $savedId (original: ${activity.id})',);
      } catch (e, stackTrace) {
        SecureLogger.e('CRITICAL: Failed to save activity to Firestore',
            error: e, stackTrace: stackTrace,);
        final message = _errorHandler.handleError(e, type: ErrorType.server);
        emit(ActivityError(message: message));
        return;
      }

      // Update user XP and points
      try {
        await _userRepository.addXp(userId, xp);
        SecureLogger.i('User XP updated');
      } catch (e, stackTrace) {
        SecureLogger.w('Failed to update user XP (non-critical): $e',
            error: e, stackTrace: stackTrace,);
        // Continue even if XP update fails
      }

      // Update streak
      try {
        await _updateStreak(userId);
        SecureLogger.i('Streak updated');
      } catch (e, stackTrace) {
        SecureLogger.w('Failed to update streak (non-critical): $e',
            error: e, stackTrace: stackTrace,);
        // Continue even if streak update fails
      }

      SecureLogger.i('Activity created successfully: ${activity.id}');
      SecureLogger.i('Firestore document ID: $savedId');

      // First, verify the document exists by reading it directly
      try {
        final verifiedActivity = await _activityRepository.getActivityById(savedId);
        if (verifiedActivity != null) {
          SecureLogger.i('Verified: Activity document exists and can be loaded');
          SecureLogger.i('Verified activity userId: ${verifiedActivity.userId}, expected: $userId');
          SecureLogger.i('Verified activity date: ${verifiedActivity.date}');
        } else {
          SecureLogger.e('ERROR: Activity document exists but cannot be loaded!');
        }
      } catch (e, stackTrace) {
        SecureLogger.e('Error verifying activity document',
            error: e, stackTrace: stackTrace,);
      }

      // Wait a moment for Firestore to be ready, then reload
      // Use a longer delay to ensure Firestore has indexed the new document
      await Future.delayed(const Duration(milliseconds: 1500));

      // Try to reload activities multiple times if needed (with exponential backoff)
      List<ActivityModel> activities = [];
      bool foundActivity = false;

      for (int attempt = 0; attempt < 3; attempt++) {
        try {
          SecureLogger.i(
              'Reloading activities after creation (attempt ${attempt + 1}/3)...',);
          activities = await _activityRepository.getActivities(userId);
          SecureLogger.i('Reloaded ${activities.length} activities after creation');
          SecureLogger
              .i('Looking for activity with ID: $savedId (Firestore doc ID)');
          SecureLogger.i(
              'Loaded activity IDs: ${activities.map((a) => a.id).toList()}',);

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
                a.duration == activity.duration,);
            if (foundActivity) {
              SecureLogger.i('Found activity by matching fields (not by ID)');
            }
          }

          SecureLogger.i('New activity found in reloaded list: $foundActivity');

          if (foundActivity) {
            SecureLogger.i('Activity found on attempt ${attempt + 1}');
            break; // Found it, exit loop
          }

          if (attempt < 2) {
            // Wait a bit longer before next attempt
            final delayMs = 800 * (attempt + 1);
            SecureLogger
                .i('Activity not found, waiting ${delayMs}ms before retry...');
            await Future.delayed(Duration(milliseconds: delayMs));
          }
        } catch (e, stackTrace) {
          SecureLogger.e('Error reloading activities (attempt ${attempt + 1})',
              error: e, stackTrace: stackTrace,);
          if (attempt == 2) {
            // Last attempt failed, but still emit what we have
            break;
          }
          await Future.delayed(Duration(milliseconds: 800 * (attempt + 1)));
        }
      }

      // If still not found, try to get it directly and add it to the list
      if (!foundActivity) {
        SecureLogger.w(
            'WARNING: New activity not found in reloaded list after 3 attempts!',);
        SecureLogger
            .w('Activity UUID: ${activity.id}, Saved Firestore ID: $savedId');
        SecureLogger
            .w('Activity userId: ${activity.userId}, Current userId: $userId');
        SecureLogger.w(
            'Activity type: ${activity.type.name}, duration: ${activity.duration}',);
        SecureLogger.w('Activity date: ${activity.date}');
        SecureLogger.w('Loaded ${activities.length} activities');
        if (activities.isNotEmpty) {
          SecureLogger.w(
              'First loaded activity: userId=${activities.first.userId}, type=${activities.first.type.name}',);
        }
        
        // Try to get the activity directly and add it to the list
        try {
          final directActivity = await _activityRepository.getActivityById(savedId);
          if (directActivity != null) {
            SecureLogger.i('Found activity by direct lookup, adding to list');
            // Check if it's not already in the list (by ID)
            if (!activities.any((a) => a.id == savedId)) {
              activities.insert(0, directActivity); // Add at the beginning
              SecureLogger.i('Added activity to list directly. New count: ${activities.length}');
              foundActivity = true;
            }
          } else {
            SecureLogger.e('Activity cannot be loaded even by direct lookup!');
          }
        } catch (e, stackTrace) {
          SecureLogger.e('Error loading activity directly',
              error: e, stackTrace: stackTrace,);
        }
      }

      // Always emit ActivityLoaded to trigger listener
      emit(ActivityLoaded(activities: activities));
      SecureLogger.i('Emitted ActivityLoaded with ${activities.length} activities');
    } catch (e, stackTrace) {
      SecureLogger.e('Error creating activity',
          error: e, stackTrace: stackTrace,);
      final message = _errorHandler.handleError(e, type: ErrorType.server);
      emit(ActivityError(message: message));
    }
  }

  Future<void> _onActivityUpdateRequested(
    ActivityUpdateRequested event,
    Emitter<ActivityState> emit,
  ) async {
    try {
      await _activityRepository.updateActivity(event.activity);
      SecureLogger.i('Activity updated: ${event.activity.id}');
    } catch (e, stackTrace) {
      SecureLogger.e('Error updating activity',
          error: e, stackTrace: stackTrace,);
      final message = _errorHandler.handleError(e, type: ErrorType.server);
      emit(ActivityError(message: message));
    }
  }

  Future<void> _onActivityDeleteRequested(
    ActivityDeleteRequested event,
    Emitter<ActivityState> emit,
  ) async {
    try {
      await _activityRepository.deleteActivity(event.activityId);
      SecureLogger.i('Activity deleted: ${event.activityId}');
    } catch (e, stackTrace) {
      SecureLogger.e('Error deleting activity',
          error: e, stackTrace: stackTrace,);
      final message = _errorHandler.handleError(e, type: ErrorType.server);
      emit(ActivityError(message: message));
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
      SecureLogger.e('Error updating streak',
          error: e, stackTrace: stackTrace,);
    }
  }
}
