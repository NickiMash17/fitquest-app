// lib/core/utils/achievement_image_helper.dart
import 'package:flutter/material.dart';
import 'package:fitquest/shared/models/achievement_model.dart';
import 'package:fitquest/core/utils/image_url_helper.dart';

/// Helper class for getting achievement-related images and icons
class AchievementImageHelper {
  /// Get the badge image URL (preferred - uses online images)
  static String? getBadgeImageUrl(
      AchievementType type, AchievementRarity rarity) {
    return ImageUrlHelper.getAchievementBadgeUrl(type, rarity);
  }

  /// Get the badge image asset path for an achievement (fallback)
  static String getBadgeImagePath(
      AchievementType type, AchievementRarity rarity) {
    final rarityName = rarity.name;
    final typeName = type.name;
    return 'assets/images/badges/${typeName}_${rarityName}.png';
  }

  /// Get the placeholder badge image path
  static String getPlaceholderBadgePath() {
    return 'assets/images/badges/placeholder.png';
  }

  /// Get the locked badge image URL (preferred)
  static String? getLockedBadgeUrl(AchievementRarity rarity) {
    return ImageUrlHelper.getLockedBadgeUrl(rarity);
  }

  /// Get the locked badge image path (fallback)
  static String getLockedBadgePath(AchievementRarity rarity) {
    return 'assets/images/badges/locked_${rarity.name}.png';
  }

  /// Get the fallback icon for an achievement type
  static IconData getAchievementIcon(AchievementType type) {
    switch (type) {
      case AchievementType.streak:
        return Icons.local_fire_department_rounded;
      case AchievementType.xp:
        return Icons.star_rounded;
      case AchievementType.activities:
        return Icons.directions_run_rounded;
      case AchievementType.level:
        return Icons.emoji_events_rounded;
      case AchievementType.special:
        return Icons.diamond_rounded;
    }
  }
}
