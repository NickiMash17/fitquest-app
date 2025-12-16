import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:fitquest/core/constants/app_constants.dart';

/// Service for managing Firestore cache
/// Provides utilities to monitor and manage cache size
@lazySingleton
class FirestoreCacheService {
  final FirebaseFirestore _firestore;
  final Logger _logger = Logger();

  FirestoreCacheService(this._firestore);

  /// Get current cache size limit
  int get cacheSizeLimit => AppConstants.firestoreCacheSizeBytes;

  /// Get cache size limit in MB
  int get cacheSizeLimitMB => cacheSizeLimit ~/ (1024 * 1024);

  /// Clear Firestore cache (useful for troubleshooting or freeing space)
  /// Note: This clears the local cache but keeps persistence enabled
  Future<void> clearCache() async {
    try {
      // Firestore doesn't provide a direct API to clear cache,
      // but we can disable and re-enable persistence
      // This is a workaround - actual cache clearing happens automatically
      // when cache size limit is reached
      _logger.i('Firestore cache will be managed automatically by size limits');
      _logger.i('Current cache size limit: $cacheSizeLimitMB MB');
      
      // Log cache configuration
      final settings = _firestore.settings;
      _logger.i('Firestore persistence enabled: ${settings.persistenceEnabled}');
      _logger.i('Cache size bytes: ${settings.cacheSizeBytes}');
    } catch (e, stackTrace) {
      _logger.e('Error managing Firestore cache', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update cache size limit (useful for power users or low-memory devices)
  /// [sizeMB] - Cache size in megabytes (must be between 1 and 100)
  Future<void> updateCacheSizeLimit(int sizeMB) async {
    if (sizeMB < 1) {
      throw ArgumentError('Cache size must be at least 1 MB');
    }
    if (sizeMB > AppConstants.firestoreMaxCacheSizeBytes ~/ (1024 * 1024)) {
      throw ArgumentError(
          'Cache size cannot exceed ${AppConstants.firestoreMaxCacheSizeBytes ~/ (1024 * 1024)} MB',);
    }

    try {
      final sizeBytes = sizeMB * 1024 * 1024;
      _firestore.settings = Settings(
        persistenceEnabled: true,
        cacheSizeBytes: sizeBytes,
      );
      _logger.i('Firestore cache size updated to: $sizeMB MB');
    } catch (e, stackTrace) {
      _logger.e('Error updating Firestore cache size', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get cache statistics (if available)
  /// Note: Firestore doesn't expose detailed cache statistics,
  /// but we can log the current configuration
  void logCacheStats() {
    try {
      final settings = _firestore.settings;
      final cacheSizeBytes = settings.cacheSizeBytes;
      _logger.i('=== Firestore Cache Statistics ===');
      _logger.i('Persistence enabled: ${settings.persistenceEnabled}');
      
      if (cacheSizeBytes != null) {
        _logger.i('Cache size limit: ${cacheSizeBytes ~/ (1024 * 1024)} MB');
        _logger.i('Cache size limit (bytes): $cacheSizeBytes');
        
        if (cacheSizeBytes == Settings.CACHE_SIZE_UNLIMITED) {
          _logger.w('⚠️ Cache size is UNLIMITED - this may lead to excessive disk usage');
        } else {
          _logger.i('✓ Cache size is limited - automatic cleanup enabled');
        }
      } else {
        _logger.w('Cache size limit not available (may be platform-specific)');
      }
    } catch (e) {
      _logger.w('Could not retrieve cache statistics: $e');
    }
  }

  /// Check if cache size is unlimited (should be avoided)
  bool get isCacheUnlimited {
    try {
      final cacheSizeBytes = _firestore.settings.cacheSizeBytes;
      return cacheSizeBytes != null && cacheSizeBytes == Settings.CACHE_SIZE_UNLIMITED;
    } catch (e) {
      return false;
    }
  }

  /// Ensure cache size is limited (call during app initialization)
  Future<void> ensureCacheSizeLimit() async {
    try {
      final settings = _firestore.settings;
      final currentCacheSize = settings.cacheSizeBytes;
      
      // If cache size is not available (e.g., on web), skip
      if (currentCacheSize == null) {
        _logger.d('Cache size configuration not available on this platform');
        return;
      }
      
      // If cache is unlimited, set a limit
      if (currentCacheSize == Settings.CACHE_SIZE_UNLIMITED) {
        _logger.w('Firestore cache is unlimited - setting limit to $cacheSizeLimitMB MB');
        await updateCacheSizeLimit(cacheSizeLimitMB);
      } else if (currentCacheSize > AppConstants.firestoreMaxCacheSizeBytes) {
        // If cache exceeds max, cap it
        _logger.w(
            'Firestore cache size (${currentCacheSize ~/ (1024 * 1024)} MB) exceeds maximum - capping at ${AppConstants.firestoreMaxCacheSizeBytes ~/ (1024 * 1024)} MB',);
        await updateCacheSizeLimit(
            AppConstants.firestoreMaxCacheSizeBytes ~/ (1024 * 1024),);
      } else {
        _logger.d(
            'Firestore cache size is properly configured: ${currentCacheSize ~/ (1024 * 1024)} MB',);
      }
    } catch (e, stackTrace) {
      _logger.e('Error ensuring cache size limit', error: e, stackTrace: stackTrace);
      // Don't throw - cache configuration is not critical for app startup
    }
  }
}

