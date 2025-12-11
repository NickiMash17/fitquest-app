import 'dart:async';
import 'package:fitquest/core/utils/secure_logger.dart';

/// Utility class for retrying operations with exponential backoff
class RetryUtils {
  /// Retry an operation with exponential backoff
  /// 
  /// [operation] - The async operation to retry
  /// [maxAttempts] - Maximum number of retry attempts (default: 3)
  /// [initialDelay] - Initial delay before first retry (default: 1 second)
  /// [maxDelay] - Maximum delay between retries (default: 30 seconds)
  /// [onRetry] - Optional callback called before each retry
  /// 
  /// Returns the result of the operation if successful
  /// Throws the last exception if all retries fail
  static Future<T> retryWithBackoff<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 30),
    void Function(int attempt, Exception error)? onRetry,
  }) async {
    int attempt = 0;
    Exception? lastException;

    while (attempt < maxAttempts) {
      try {
        return await operation();
      } on Exception catch (e) {
        lastException = e;
        attempt++;

        if (attempt >= maxAttempts) {
          SecureLogger.w(
            'Retry failed after $maxAttempts attempts: ${e.toString()}',
          );
          rethrow;
        }

        // Calculate delay with exponential backoff
        final delay = Duration(
          milliseconds: (initialDelay.inMilliseconds * (1 << (attempt - 1)))
              .clamp(0, maxDelay.inMilliseconds),
        );

        SecureLogger.d(
          'Retry attempt $attempt/$maxAttempts after ${delay.inMilliseconds}ms',
        );

        onRetry?.call(attempt, e);
        await Future.delayed(delay);
      }
    }

    throw lastException ?? Exception('Retry failed: unknown error');
  }

  /// Retry an operation with fixed delay
  static Future<T> retryWithFixedDelay<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
    void Function(int attempt, Exception error)? onRetry,
  }) async {
    return retryWithBackoff(
      operation: operation,
      maxAttempts: maxAttempts,
      initialDelay: delay,
      maxDelay: delay,
      onRetry: onRetry,
    );
  }

  /// Retry an operation only on specific exceptions
  static Future<T> retryOnExceptions<T>({
    required Future<T> Function() operation,
    required List<Type> retryableExceptions,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 30),
  }) async {
    int attempt = 0;
    Exception? lastException;

    while (attempt < maxAttempts) {
      try {
        return await operation();
      } on Exception catch (e) {
        lastException = e;

        // Check if this exception type should be retried
        final shouldRetry = retryableExceptions.any(
          (type) => e.runtimeType == type,
        );

        if (!shouldRetry) {
          SecureLogger.d('Exception ${e.runtimeType} is not retryable');
          rethrow;
        }

        attempt++;

        if (attempt >= maxAttempts) {
          SecureLogger.w(
            'Retry failed after $maxAttempts attempts: ${e.toString()}',
          );
          rethrow;
        }

        // Calculate delay with exponential backoff
        final delay = Duration(
          milliseconds: (initialDelay.inMilliseconds * (1 << (attempt - 1)))
              .clamp(0, maxDelay.inMilliseconds),
        );

        SecureLogger.d(
          'Retrying on ${e.runtimeType} (attempt $attempt/$maxAttempts)',
        );

        await Future.delayed(delay);
      }
    }

    throw lastException ?? Exception('Retry failed: unknown error');
  }
}

