import 'package:logger/logger.dart';
import 'package:fitquest/core/utils/logger.dart';

/// Secure logger that removes sensitive data before logging
/// Prevents passwords, tokens, and other sensitive information from appearing in logs
class SecureLogger {
  static final Logger _logger = appLogger;

  /// List of sensitive field names that should be redacted
  static const List<String> _sensitiveFields = [
    'password',
    'token',
    'accessToken',
    'refreshToken',
    'apiKey',
    'secret',
    'authToken',
    'credential',
    'privateKey',
    'ssn',
    'creditCard',
    'cvv',
  ];

  /// Sanitize data by removing sensitive fields
  static dynamic _sanitizeData(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final sanitized = <String, dynamic>{};
      data.forEach((key, value) {
        final keyString = key.toString().toLowerCase();
        
        // Check if this is a sensitive field
        final isSensitive = _sensitiveFields.any(
          (field) => keyString.contains(field.toLowerCase()),
        );

        if (isSensitive) {
          sanitized[key] = '[REDACTED]';
        } else if (value is Map) {
          sanitized[key] = _sanitizeData(value);
        } else if (value is List) {
          sanitized[key] = value.map((item) => _sanitizeData(item)).toList();
        } else {
          sanitized[key] = value;
        }
      });
      return sanitized;
    }

    if (data is List) {
      return data.map((item) => _sanitizeData(item)).toList();
    }

    // Check if string contains sensitive patterns
    if (data is String) {
      // Redact email addresses (keep domain)
      if (data.contains('@')) {
        final parts = data.split('@');
        if (parts.length == 2) {
          return '${parts[0][0]}***@${parts[1]}';
        }
      }
      
      // Redact potential tokens (long alphanumeric strings)
      if (data.length > 20 && RegExp(r'^[A-Za-z0-9]+$').hasMatch(data)) {
        return '${data.substring(0, 4)}***${data.substring(data.length - 4)}';
      }
    }

    return data;
  }

  /// Log debug message with sanitized data
  static void d(String message, {dynamic error, StackTrace? stackTrace}) {
    final sanitizedError = error != null ? _sanitizeData(error) : null;
    _logger.d(message, error: sanitizedError, stackTrace: stackTrace);
  }

  /// Log info message with sanitized data
  static void i(String message, {dynamic error, StackTrace? stackTrace}) {
    final sanitizedError = error != null ? _sanitizeData(error) : null;
    _logger.i(message, error: sanitizedError, stackTrace: stackTrace);
  }

  /// Log warning message with sanitized data
  static void w(String message, {dynamic error, StackTrace? stackTrace}) {
    final sanitizedError = error != null ? _sanitizeData(error) : null;
    _logger.w(message, error: sanitizedError, stackTrace: stackTrace);
  }

  /// Log error message with sanitized data
  static void e(String message, {dynamic error, StackTrace? stackTrace}) {
    final sanitizedError = error != null ? _sanitizeData(error) : null;
    _logger.e(message, error: sanitizedError, stackTrace: stackTrace);
  }

  /// Log fatal error with sanitized data
  static void f(String message, {dynamic error, StackTrace? stackTrace}) {
    final sanitizedError = error != null ? _sanitizeData(error) : null;
    _logger.f(message, error: sanitizedError, stackTrace: stackTrace);
  }
}

