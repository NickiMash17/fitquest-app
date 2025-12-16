import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:injectable/injectable.dart';
import 'package:fitquest/core/utils/secure_logger.dart';
import 'package:fitquest/core/constants/app_constants.dart';

/// Error types for categorization
enum ErrorType {
  network,
  authentication,
  validation,
  server,
  permission,
  notFound,
  rateLimit,
  unknown,
}

/// Comprehensive error handling service
/// Handles errors consistently across the app with proper logging, analytics, and user feedback
@lazySingleton
class ErrorHandlerService {
  final FirebaseCrashlytics _crashlytics;
  final FirebaseAnalytics _analytics;

  ErrorHandlerService(this._crashlytics, this._analytics);

  /// Handle error and return user-friendly message
  String handleError(dynamic error, {ErrorType? type}) {
    final errorType = type ?? _categorizeError(error);
    final message = _getUserFriendlyMessage(error, errorType);
    
    // Log error securely
    SecureLogger.e(
      'Error occurred: ${error.toString()}',
      error: error,
    );
    
    // Report to Crashlytics (non-fatal)
    _crashlytics.recordError(
      error,
      null,
      reason: errorType.name,
      fatal: false,
    );
    
    // Track in analytics
    _analytics.logEvent(
      name: 'error_occurred',
      parameters: {
        'error_type': errorType.name,
        'error_message': message,
      },
    );
    
    return message;
  }

  /// Show error to user via SnackBar
  void showError(BuildContext context, dynamic error, {ErrorType? type}) {
    final message = handleError(error, type: type);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show error dialog
  void showErrorDialog(
    BuildContext context,
    dynamic error, {
    ErrorType? type,
    VoidCallback? onRetry,
  }) {
    final message = handleError(error, type: type);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  /// Categorize error type
  ErrorType _categorizeError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') ||
        errorString.contains('internet') ||
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return ErrorType.network;
    }
    
    if (errorString.contains('auth') ||
        errorString.contains('login') ||
        errorString.contains('unauthorized') ||
        errorString.contains('permission denied')) {
      return ErrorType.authentication;
    }
    
    if (errorString.contains('validation') ||
        errorString.contains('invalid') ||
        errorString.contains('required')) {
      return ErrorType.validation;
    }
    
    if (errorString.contains('not found') ||
        errorString.contains('404')) {
      return ErrorType.notFound;
    }
    
    if (errorString.contains('rate limit') ||
        errorString.contains('too many requests')) {
      return ErrorType.rateLimit;
    }
    
    if (errorString.contains('permission') ||
        errorString.contains('denied')) {
      return ErrorType.permission;
    }
    
    if (errorString.contains('server') ||
        errorString.contains('500') ||
        errorString.contains('503')) {
      return ErrorType.server;
    }
    
    return ErrorType.unknown;
  }

  /// Get user-friendly error message
  String _getUserFriendlyMessage(dynamic error, ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return AppConstants.networkErrorMessage;
      case ErrorType.authentication:
        return AppConstants.authErrorMessage;
      case ErrorType.validation:
        if (error is String) {
          return error; // Return validation message as-is
        }
        return 'Please check your input and try again';
      case ErrorType.notFound:
        return 'The requested item was not found';
      case ErrorType.rateLimit:
        return 'Too many requests. Please try again later';
      case ErrorType.permission:
        return 'You don\'t have permission to perform this action';
      case ErrorType.server:
        return 'Server error. Please try again later';
      case ErrorType.unknown:
        return AppConstants.genericErrorMessage;
    }
  }

  /// Handle Firebase exceptions specifically
  /// Handles both FirebaseException (Firestore) and FirebaseAuthException (Auth)
  String handleFirebaseException(dynamic error) {
    // Handle Firebase Auth exceptions
    if (error is firebase_auth.FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email';
        case 'wrong-password':
          return 'Incorrect password';
        case 'invalid-credential':
          return 'Invalid email or password. Please try again.';
        case 'user-token-expired':
          return 'Your session has expired. Please sign in again.';
        case 'email-already-in-use':
          return 'Email is already registered';
        case 'weak-password':
          return 'Password is too weak. Please use a stronger password.';
        case 'invalid-email':
          return 'Invalid email address';
        case 'user-disabled':
          return 'This account has been disabled';
        case 'too-many-requests':
          return 'Too many login attempts. Please try again later.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled';
        case 'network-request-failed':
          return AppConstants.networkErrorMessage;
        default:
          return 'Authentication failed. Please try again.';
      }
    }
    
    // Handle Firestore exceptions
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'You don\'t have permission to access this resource';
        case 'unavailable':
          return AppConstants.networkErrorMessage;
        case 'deadline-exceeded':
          return 'Request timed out. Please try again';
        case 'not-found':
          return 'The requested item was not found';
        case 'already-exists':
          return 'This item already exists';
        case 'failed-precondition':
          return 'Please complete the required setup first';
        default:
          return handleError(error, type: ErrorType.server);
      }
    }
    
    return handleError(error);
  }
}

