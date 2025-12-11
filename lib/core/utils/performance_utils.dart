import 'dart:async';
import 'package:flutter/foundation.dart';

/// Performance utilities for optimizing app performance
class PerformanceUtils {
  /// Debounce function - delays execution until after wait time has passed
  /// Useful for search inputs, scroll events, etc.
  static Timer? _debounceTimer;

  static void debounce(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  /// Throttle function - limits function execution to once per wait time
  /// Useful for button clicks, scroll events, etc.
  static DateTime? _lastExecution;
  static Timer? _throttleTimer;

  static void throttle(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    final now = DateTime.now();
    if (_lastExecution == null ||
        now.difference(_lastExecution!) >= delay) {
      _lastExecution = now;
      callback();
    } else {
      _throttleTimer?.cancel();
      _throttleTimer = Timer(
        delay - now.difference(_lastExecution!),
        callback,
      );
    }
  }

  /// Measure execution time of a function
  static T measureExecution<T>(
    T Function() callback, {
    String? label,
    void Function(Duration)? onComplete,
  }) {
    final stopwatch = Stopwatch()..start();
    try {
      final result = callback();
      stopwatch.stop();
      if (kDebugMode && label != null) {
        debugPrint('[$label] Execution time: ${stopwatch.elapsedMilliseconds}ms');
      }
      onComplete?.call(stopwatch.elapsed);
      return result;
    } catch (e) {
      stopwatch.stop();
      rethrow;
    }
  }

  /// Measure async execution time
  static Future<T> measureAsyncExecution<T>(
    Future<T> Function() callback, {
    String? label,
    void Function(Duration)? onComplete,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await callback();
      stopwatch.stop();
      if (kDebugMode && label != null) {
        debugPrint('[$label] Execution time: ${stopwatch.elapsedMilliseconds}ms');
      }
      onComplete?.call(stopwatch.elapsed);
      return result;
    } catch (e) {
      stopwatch.stop();
      rethrow;
    }
  }

  /// Dispose all timers
  static void dispose() {
    _debounceTimer?.cancel();
    _throttleTimer?.cancel();
    _debounceTimer = null;
    _throttleTimer = null;
    _lastExecution = null;
  }
}

