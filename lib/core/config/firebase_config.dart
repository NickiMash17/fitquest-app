import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:fitquest/firebase_options.dart';

/// Firebase configuration and initialization
class FirebaseConfig {
  static final Logger _logger = Logger();

  /// Initialize Firebase services
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _logger.i('Firebase initialized successfully');

      // Setup Crashlytics (only on non-web platforms)
      // Crashlytics is not supported on web, so skip it entirely
      if (!kIsWeb) {
        try {
          // Check if Crashlytics is available before setting up handlers
          final crashlytics = FirebaseCrashlytics.instance;
          
          // Set up error handlers only if Crashlytics is available
          FlutterError.onError = (errorDetails) {
            // Filter out asset loading errors - these are expected and shouldn't be reported
            final errorString = errorDetails.exception.toString();
            if (errorString.contains('Unable to load asset') ||
                errorString.contains('HTTP request succeeded') ||
                errorString.contains('404')) {
              // Silently ignore asset loading errors
              return;
            }
            
            // Only record if Crashlytics is available
            try {
              crashlytics.recordFlutterFatalError(errorDetails);
            } catch (e) {
              // Crashlytics not available, just log
              _logger.w('Crashlytics error recording failed: $e');
            }
          };

          // Pass non-fatal errors from the framework to Crashlytics
          PlatformDispatcher.instance.onError = (error, stack) {
            // Filter out asset loading errors
            final errorString = error.toString();
            if (errorString.contains('Unable to load asset') ||
                errorString.contains('HTTP request succeeded') ||
                errorString.contains('404')) {
              // Silently ignore asset loading errors
              return true;
            }
            
            try {
              crashlytics.recordError(error, stack, fatal: true);
            } catch (e) {
              // Crashlytics not available, just log
              _logger.w('Crashlytics error recording failed: $e');
            }
            return true;
          };

          _logger.i('Crashlytics configured');
        } catch (e) {
          _logger.w('Crashlytics initialization failed (may not be available on this platform): $e');
          // Set up basic error handlers that don't use Crashlytics
          FlutterError.onError = (errorDetails) {
            _logger.e('Flutter error: ${errorDetails.exception}');
          };
        }
      } else {
        _logger.i('Crashlytics skipped on web platform');
        // Set up basic error handlers for web that don't use Crashlytics
        FlutterError.onError = (errorDetails) {
          // Filter out asset loading errors
          final errorString = errorDetails.exception.toString();
          if (errorString.contains('Unable to load asset') ||
              errorString.contains('HTTP request succeeded') ||
              errorString.contains('404')) {
            // Silently ignore asset loading errors
            return;
          }
          _logger.e('Flutter error: ${errorDetails.exception}');
        };
      }
    } catch (e, stackTrace) {
      _logger.e('Error initializing Firebase', error: e, stackTrace: stackTrace);
      // Don't rethrow - allow app to continue even if Firebase fails
    }
  }
}

