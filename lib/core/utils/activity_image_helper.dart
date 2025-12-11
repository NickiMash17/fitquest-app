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
  /// Returns null since we use network images and icon fallbacks
  static String? getActivityImagePath(ActivityType type) {
    // No local assets - using network images and icon fallbacks
    return null;
  }

  /// Get the placeholder image path for an activity type
  /// Returns null since we use network images and icon fallbacks
  static String? getActivityPlaceholderPath(ActivityType type) {
    // No local assets - using network images and icon fallbacks
    return null;
  }

  /// Get the image URL for quick actions (preferred - uses online images)
  static String? getQuickActionImageUrl(ActivityType type) {
    return ImageUrlHelper.getQuickActionImageUrl(type);
  }

  /// Get the icon for quick actions (fallback)
  /// Returns null since we use network images and icon fallbacks
  static String? getQuickActionImagePath(ActivityType type) {
    // No local assets - using network images and icon fallbacks
    return null;
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
