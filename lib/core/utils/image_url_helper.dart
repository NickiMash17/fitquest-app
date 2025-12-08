// lib/core/utils/image_url_helper.dart
import 'package:fitquest/shared/models/activity_model.dart';
import 'package:fitquest/shared/models/achievement_model.dart';

/// Helper class for getting image URLs from online sources
class ImageUrlHelper {
  /// Get plant companion image URL based on evolution stage
  /// Returns null to prioritize local assets, falls back to Unsplash if needed
  static String? getPlantImageUrl(int evolutionStage) {
    // Return null to prioritize local assets first
    // The ImageWithFallback widget will use assetPath first, then fall back to these URLs
    // Stage 0-1: Seed, Stage 2: Sprout, Stage 3: Sapling, Stage 4: Tree, Stage 5+: Ancient Tree
    if (evolutionStage <= 1) {
      return 'https://images.unsplash.com/photo-1516253593875-bd7ba052fbc5?w=400&h=400&fit=crop&auto=format';
    } else if (evolutionStage <= 2) {
      return 'https://images.unsplash.com/photo-1466692476868-aef1dfb1e735?w=400&h=400&fit=crop&auto=format';
    } else if (evolutionStage <= 3) {
      return 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400&h=400&fit=crop&auto=format';
    } else if (evolutionStage <= 4) {
      return 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&h=400&fit=crop&auto=format';
    } else {
      return 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&h=400&fit=crop&auto=format';
    }
  }

  /// Get activity image URL
  static String getActivityImageUrl(ActivityType type) {
    switch (type) {
      case ActivityType.exercise:
        return 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=300&fit=crop&auto=format';
      case ActivityType.meditation:
        return 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=300&h=300&fit=crop&auto=format';
      case ActivityType.hydration:
        return 'https://images.unsplash.com/photo-1523362628745-0c100150b504?w=300&h=300&fit=crop&auto=format';
      case ActivityType.sleep:
        return 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=300&h=300&fit=crop&auto=format';
    }
  }

  /// Get quick action image URL
  static String getQuickActionImageUrl(ActivityType type) {
    switch (type) {
      case ActivityType.exercise:
        return 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=200&h=200&fit=crop&auto=format';
      case ActivityType.meditation:
        return 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=200&h=200&fit=crop&auto=format';
      case ActivityType.hydration:
        return 'https://images.unsplash.com/photo-1523362628745-0c100150b504?w=200&h=200&fit=crop&auto=format';
      case ActivityType.sleep:
        return 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=200&h=200&fit=crop&auto=format';
    }
  }

  /// Get achievement badge image URL
  static String getAchievementBadgeUrl(
      AchievementType type, AchievementRarity rarity) {
    // Using placeholder service with themed images
    return 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=200&h=200&fit=crop&auto=format';
  }

  /// Get locked achievement badge URL
  static String getLockedBadgeUrl(AchievementRarity rarity) {
    return 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=200&h=200&fit=crop&auto=format&q=50';
  }

  /// Get onboarding image URL
  static String getOnboardingImageUrl(int slideIndex) {
    switch (slideIndex) {
      case 0:
        return 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=600&h=600&fit=crop&auto=format';
      case 1:
        return 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=600&h=600&fit=crop&auto=format';
      case 2:
        return 'https://images.unsplash.com/photo-1516253593875-bd7ba052fbc5?w=600&h=600&fit=crop&auto=format';
      default:
        return 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=600&h=600&fit=crop&auto=format';
    }
  }
}
