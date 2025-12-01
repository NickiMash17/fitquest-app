import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
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

      // Setup Crashlytics
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };

      // Pass non-fatal errors from the framework to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      _logger.i('Crashlytics configured');
    } catch (e, stackTrace) {
      _logger.e('Error initializing Firebase', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

