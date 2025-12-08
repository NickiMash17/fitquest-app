// lib/core/utils/activity_image_helper.dart
import 'package:flutter/material.dart';
import 'package:fitquest/shared/models/activity_model.dart';
import 'package:fitquest/core/utils/image_url_helper.dart';

/// Helper class for getting activity-related images and icons
class ActivityImageHelper {
  /// Get the image URL for an activity type (preferred - uses online images)
  static String? getActivityImageUrl(ActivityType type) {
    return ImageUrlHelper.getActivityImageUrl(type);
  }

  /// Get the image asset path for an activity type (fallback)
  static String getActivityImagePath(ActivityType type) {
    switch (type) {
      case ActivityType.exercise:
        return 'assets/images/activities/exercise.png';
      case ActivityType.meditation:
        return 'assets/images/activities/meditation.png';
      case ActivityType.hydration:
        return 'assets/images/activities/hydration.png';
      case ActivityType.sleep:
        return 'assets/images/activities/sleep.png';
    }
  }

  /// Get the placeholder image path for an activity type
  static String getActivityPlaceholderPath(ActivityType type) {
    switch (type) {
      case ActivityType.exercise:
        return 'assets/images/activities/exercise_placeholder.png';
      case ActivityType.meditation:
        return 'assets/images/activities/meditation_placeholder.png';
      case ActivityType.hydration:
        return 'assets/images/activities/hydration_placeholder.png';
      case ActivityType.sleep:
        return 'assets/images/activities/sleep_placeholder.png';
    }
  }

  /// Get the image URL for quick actions (preferred - uses online images)
  static String? getQuickActionImageUrl(ActivityType type) {
    return ImageUrlHelper.getQuickActionImageUrl(type);
  }

  /// Get the icon for quick actions (fallback)
  static String getQuickActionImagePath(ActivityType type) {
    switch (type) {
      case ActivityType.exercise:
        return 'assets/images/activities/workout.png';
      case ActivityType.meditation:
        return 'assets/images/activities/meditate.png';
      case ActivityType.hydration:
        return 'assets/images/activities/hydrate.png';
      case ActivityType.sleep:
        return 'assets/images/activities/sleep.png';
    }
  }

  /// Get the fallback icon for an activity type
  static IconData getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.exercise:
        return Icons.directions_run_rounded;
      case ActivityType.meditation:
        return Icons.self_improvement_rounded;
      case ActivityType.hydration:
        return Icons.water_drop_rounded;
      case ActivityType.sleep:
        return Icons.nightlight_round_rounded;
    }
  }
}
