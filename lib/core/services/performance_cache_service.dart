// lib/core/services/performance_cache_service.dart
import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:fitquest/core/services/cache_service.dart';

/// Advanced performance cache service with parallel fetching and lazy loading
@lazySingleton
class PerformanceCacheService {
  final CacheService _cacheService;
  final Logger _logger = Logger();

  // In-flight requests to prevent duplicate fetches
  final Map<String, Completer<dynamic>> _inFlightRequests = {};

  // Batch request queue
  final List<_BatchRequest> _batchQueue = [];
  Timer? _batchTimer;

  PerformanceCacheService(this._cacheService);

  /// Fetch data with parallel loading and caching
  /// Returns cached data immediately if available, then updates with fresh data
  Future<T> fetchWithCache<T>({
    required String cacheKey,
    required Future<T> Function() fetchFunction,
    Duration? ttl,
    bool forceRefresh = false,
    T Function(Map<String, dynamic>)? fromJson,
    Map<String, dynamic> Function(T)? toJson,
  }) async {
    // Check if request is already in flight
    if (_inFlightRequests.containsKey(cacheKey)) {
      _logger.d('Request already in flight: $cacheKey');
      return await _inFlightRequests[cacheKey]!.future as T;
    }

    // Try cache first (unless force refresh)
    if (!forceRefresh) {
      final cached = await _cacheService.get<T>(
        cacheKey,
        fromJson: fromJson,
      );
      if (cached != null) {
        _logger.d('Cache hit: $cacheKey');
        // Fetch fresh data in background for next time
        _fetchInBackground(cacheKey, fetchFunction, ttl, fromJson, toJson);
        return cached;
      }
    }

    // Create completer for in-flight request
    final completer = Completer<T>();
    _inFlightRequests[cacheKey] = completer;

    try {
      _logger.d('Fetching fresh data: $cacheKey');
      final data = await fetchFunction();

      // Cache the result
      await _cacheService.set(
        cacheKey,
        data,
        ttl: ttl,
        toJson: toJson,
      );

      completer.complete(data);
      _inFlightRequests.remove(cacheKey);
      return data;
    } catch (e) {
      _logger.e('Error fetching $cacheKey', error: e);
      completer.completeError(e);
      _inFlightRequests.remove(cacheKey);
      rethrow;
    }
  }

  /// Fetch multiple items in parallel
  Future<Map<String, T>> fetchParallel<T>({
    required Map<String, Future<T> Function()> fetchFunctions,
    String? cacheKeyPrefix,
    Duration? ttl,
    bool forceRefresh = false,
    T Function(Map<String, dynamic>)? fromJson,
    Map<String, dynamic> Function(T)? toJson,
  }) async {
    final results = <String, T>{};
    final errors = <String, dynamic>{};

    // Create futures for all fetches
    final futures = fetchFunctions.entries.map((entry) async {
      final key = entry.key;
      final cacheKey = cacheKeyPrefix != null
          ? '$cacheKeyPrefix:$key'
          : key;

      try {
        final data = await fetchWithCache<T>(
          cacheKey: cacheKey,
          fetchFunction: entry.value,
          ttl: ttl,
          forceRefresh: forceRefresh,
          fromJson: fromJson,
          toJson: toJson,
        );
        results[key] = data;
      } catch (e) {
        errors[key] = e;
        _logger.w('Error fetching $key: $e');
      }
    });

    // Wait for all to complete
    await Future.wait(futures);

    if (errors.isNotEmpty && results.isEmpty) {
      throw Exception('All parallel fetches failed: $errors');
    }

    return results;
  }

  /// Lazy load data - returns immediately with placeholder, loads in background
  Future<T?> lazyLoad<T>({
    required String cacheKey,
    required Future<T> Function() fetchFunction,
    Duration? ttl,
    T Function(Map<String, dynamic>)? fromJson,
    Map<String, dynamic> Function(T)? toJson,
  }) async {
    // Check cache first
    final cached = await _cacheService.get<T>(
      cacheKey,
      fromJson: fromJson,
    );
    if (cached != null) {
      return cached;
    }

    // Load in background
    fetchFunction().then((data) async {
      await _cacheService.set(
        cacheKey,
        data,
        ttl: ttl,
        toJson: toJson,
      );
    }).catchError((e) {
      _logger.w('Background fetch failed for $cacheKey: $e');
    });

    return null;
  }

  /// Batch multiple requests together for efficiency
  void batchRequest({
    required String cacheKey,
    required Future<dynamic> Function() fetchFunction,
    Duration? ttl,
    Function(dynamic)? onComplete,
  }) {
    _batchQueue.add(_BatchRequest(
      cacheKey: cacheKey,
      fetchFunction: fetchFunction,
      ttl: ttl,
      onComplete: onComplete,
    ));

    // Process batch after short delay (collects multiple requests)
    _batchTimer?.cancel();
    _batchTimer = Timer(const Duration(milliseconds: 100), _processBatch);
  }

  Future<void> _processBatch() async {
    if (_batchQueue.isEmpty) return;

    final batch = List<_BatchRequest>.from(_batchQueue);
    _batchQueue.clear();

    // Execute all batch requests in parallel
    await Future.wait(
      batch.map((request) async {
        try {
          final data = await request.fetchFunction();
          await _cacheService.set(
            request.cacheKey,
            data,
            ttl: request.ttl,
          );
          request.onComplete?.call(data);
        } catch (e) {
          _logger.w('Batch request failed for ${request.cacheKey}: $e');
        }
      }),
    );
  }

  /// Fetch in background without blocking
  void _fetchInBackground<T>(
    String cacheKey,
    Future<T> Function() fetchFunction,
    Duration? ttl,
    T Function(Map<String, dynamic>)? fromJson,
    Map<String, dynamic> Function(T)? toJson,
  ) {
    Future.microtask(() async {
      try {
        final data = await fetchFunction();
        await _cacheService.set(
          cacheKey,
          data,
          ttl: ttl,
          toJson: toJson,
        );
        _logger.d('Background refresh completed: $cacheKey');
      } catch (e) {
        _logger.w('Background refresh failed: $cacheKey', error: e);
      }
    });
  }

  /// Preload data for faster access
  Future<void> preload(List<String> cacheKeys) async {
    await Future.wait(
      cacheKeys.map((key) async {
        try {
          await _cacheService.get(key);
        } catch (e) {
          _logger.w('Preload failed for $key: $e');
        }
      }),
    );
  }

  /// Clear all caches
  Future<void> clear() async {
    _inFlightRequests.clear();
    _batchQueue.clear();
    _batchTimer?.cancel();
    await _cacheService.clear();
  }
}

class _BatchRequest {
  final String cacheKey;
  final Future<dynamic> Function() fetchFunction;
  final Duration? ttl;
  final Function(dynamic)? onComplete;

  _BatchRequest({
    required this.cacheKey,
    required this.fetchFunction,
    this.ttl,
    this.onComplete,
  });
}

