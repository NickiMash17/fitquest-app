import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

/// Service for tracking analytics events
@lazySingleton
class AnalyticsService {
  final FirebaseAnalytics _analytics;
  final Logger _logger = Logger();

  AnalyticsService(this._analytics);

  /// Log a custom event
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      _logger.d('Analytics event logged: $name');
    } catch (e) {
      _logger.w('Failed to log analytics event: $e');
      // Don't throw - analytics failures shouldn't break the app
    }
  }

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      _logger.d('Screen view logged: $screenName');
    } catch (e) {
      _logger.w('Failed to log screen view: $e');
    }
  }

  /// Log user login
  Future<void> logLogin({String? loginMethod}) async {
    await logEvent(
      name: 'login',
      parameters: {
        if (loginMethod != null) 'method': loginMethod,
      },
    );
  }

  /// Log activity creation
  Future<void> logActivityCreated({
    required String activityType,
    required int duration,
    required int xpEarned,
  }) async {
    await logEvent(
      name: 'activity_created',
      parameters: {
        'activity_type': activityType,
        'duration': duration,
        'xp_earned': xpEarned,
      },
    );
  }

  /// Log achievement unlocked
  Future<void> logAchievementUnlocked({
    required String achievementId,
    required String achievementType,
  }) async {
    await logEvent(
      name: 'achievement_unlocked',
      parameters: {
        'achievement_id': achievementId,
        'achievement_type': achievementType,
      },
    );
  }

  /// Log goal created
  Future<void> logGoalCreated({
    required String goalType,
    required String targetValue,
  }) async {
    await logEvent(
      name: 'goal_created',
      parameters: {
        'goal_type': goalType,
        'target_value': targetValue,
      },
    );
  }

  /// Set user properties
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      _logger.d('User property set: $name = $value');
    } catch (e) {
      _logger.w('Failed to set user property: $e');
    }
  }

  /// Set user ID
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
      _logger.d('User ID set: $userId');
    } catch (e) {
      _logger.w('Failed to set user ID: $e');
    }
  }
}

