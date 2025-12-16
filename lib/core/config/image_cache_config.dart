import 'package:flutter/material.dart';

/// Configuration for image caching
/// Optimizes memory and disk usage for cached images
class ImageCacheConfig {
  /// Configure image cache settings globally
  static void configure() {
    // Configure Flutter's image cache - optimized for mobile performance
    // Reduced cache size for faster loading on mobile devices
    PaintingBinding.instance.imageCache.maximumSize = 50; // Max 50 images in memory (reduced from 100)
    PaintingBinding.instance.imageCache.maximumSizeBytes = 30 * 1024 * 1024; // 30 MB (reduced from 50 MB)

    // Configure CachedNetworkImage settings
    // These are set globally when the app starts
  }

  /// Clear image cache (useful for memory management)
  static void clearCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Clear cache older than specified duration
  static Future<void> evictOldCache({Duration olderThan = const Duration(days: 7)}) async {
    // This would require custom implementation with cache manager
    // For now, we'll just clear the entire cache
    clearCache();
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    final cache = PaintingBinding.instance.imageCache;
    return {
      'currentSize': cache.currentSize,
      'currentSizeBytes': cache.currentSizeBytes,
      'maximumSize': cache.maximumSize,
      'maximumSizeBytes': cache.maximumSizeBytes,
    };
  }
}

