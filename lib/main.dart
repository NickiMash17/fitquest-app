// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fitquest/core/theme/app_theme.dart';
import 'package:fitquest/core/navigation/app_router.dart';
import 'package:fitquest/core/di/injection.dart';
import 'package:fitquest/shared/services/local_storage_service.dart';
import 'package:fitquest/core/services/cache_service.dart';
import 'package:fitquest/core/services/theme_service.dart';
import 'package:fitquest/core/services/firestore_cache_service.dart';
import 'package:fitquest/core/constants/app_constants.dart';
import 'package:fitquest/core/config/firebase_config.dart';
import 'package:fitquest/core/config/image_cache_config.dart';
import 'package:fitquest/features/authentication/bloc/auth_bloc.dart';
import 'package:fitquest/features/authentication/bloc/auth_event.dart';
import 'package:fitquest/features/activities/bloc/activity_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> _initializeApp() async {
  // Initialize dependency injection FIRST (needed for everything else)
  configureDependencies();

  // Preload Google Fonts in parallel (non-blocking)
  GoogleFonts.pendingFonts([
    GoogleFonts.fredoka(),
    GoogleFonts.nunito(),
  ]);

  // Initialize Firebase (critical - needed for auth)
  await FirebaseConfig.initialize();

  // Initialize theme service (needed for app startup)
  await getIt<ThemeService>().initialize();

  // Initialize local storage (needed for app state)
  await getIt<LocalStorageService>().init();

  // Defer non-critical initializations to after app starts
  // These can be done in background
  _initializeNonCriticalServices();
}

// Initialize non-critical services in background (doesn't block app startup)
void _initializeNonCriticalServices() {
  // Run in background without blocking
  Future.microtask(() async {
    try {
      // Initialize Hive (skip on web if it fails)
      try {
        await Hive.initFlutter();
        debugPrint('Hive initialized');
      } catch (e) {
        debugPrint('Hive initialization skipped: $e');
      }

      // Enable Firestore persistence for offline support with cache size limits
      try {
        final firestore = FirebaseFirestore.instance;
        firestore.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: AppConstants.firestoreCacheSizeBytes,
        );
        debugPrint(
          'Firestore persistence enabled with cache size: ${AppConstants.firestoreCacheSizeBytes ~/ (1024 * 1024)} MB',
        );
      } catch (e) {
        debugPrint('Firestore persistence setup skipped: $e');
      }

      // Initialize Firestore cache service (can be done later)
      debugPrint('Initializing Firestore cache service...');
      try {
        final firestoreCacheService = getIt<FirestoreCacheService>();
        await firestoreCacheService.ensureCacheSizeLimit();
        firestoreCacheService.logCacheStats();
        debugPrint('Firestore cache service initialized');
      } catch (e) {
        debugPrint('Firestore cache service initialization skipped: $e');
      }

      // Initialize cache service (can be done later)
      debugPrint('Initializing cache service...');
      await getIt<CacheService>().init();
      debugPrint('Cache service initialized');

      // Configure image cache (can be done later)
      debugPrint('Configuring image cache...');
      ImageCacheConfig.configure();
      debugPrint('Image cache configured');
    } catch (e) {
      debugPrint('Non-critical service initialization error: $e');
      // Don't throw - these are non-critical
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Replace default red error widget with custom error handler
  // This MUST be set before runApp() to catch all errors
  ErrorWidget.builder = (FlutterErrorDetails details) {
    // Log the error for debugging (only in debug mode)
    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('ErrorWidget caught: ${details.exception}');
      debugPrint('Library: ${details.library}');
      if (details.stack != null) {
        debugPrint('Stack: ${details.stack}');
      }
      debugPrint('═══════════════════════════════════════════════════════════');
    }
    
    // Return completely invisible widget - NO red banner, NO yellow stripes, NO "Need help?" button
    // This completely replaces Flutter's default red error widget
    return const SizedBox.shrink();
  };
  
  // Suppress FlutterError to prevent red error widget
  // This will be overridden by FirebaseConfig for non-web, but for web it stays
  FlutterError.onError = (FlutterErrorDetails details) {
    // Log but don't show error widget
    if (kDebugMode) {
      debugPrint('FlutterError suppressed: ${details.exception}');
    }
    // Don't call default handler - this prevents the red error widget
  };

  // Note: Error handlers may be set up in FirebaseConfig.initialize()
  // But ErrorWidget.builder here takes precedence

  // Initialize first, then show app
  try {
    await _initializeApp();
  } catch (e, stackTrace) {
    // Log error but continue - app will show error if needed
    // Only log in debug mode to avoid performance impact
    assert(() {
      debugPrint('Initialization error: $e');
      debugPrint('Stack: $stackTrace');
      return true;
    }());
  }

  runApp(const FitQuestApp());
}

class FitQuestApp extends StatefulWidget {
  const FitQuestApp({super.key});

  @override
  State<FitQuestApp> createState() => _FitQuestAppState();
}

class _FitQuestAppState extends State<FitQuestApp> {
  late ThemeService _themeService;

  @override
  void initState() {
    super.initState();
    _themeService = getIt<ThemeService>();
    // Ensure theme service is initialized
    _themeService.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
    // Listen to theme changes reactively
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      debugPrint(
          'Theme changed callback triggered, current mode: ${_themeService.themeMode}');
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) {
              try {
                final bloc = getIt<AuthBloc>();
                bloc.add(const AuthCheckRequested());
                return bloc;
              } catch (e, stackTrace) {
                // Return a basic AuthBloc if DI fails (silent in production)
                assert(() {
                  debugPrint('Error creating AuthBloc: $e');
                  debugPrint('Stack: $stackTrace');
                  return true;
                }());
                try {
                  return AuthBloc(getIt(), getIt(), getIt());
                } catch (e2) {
                  assert(() {
                    debugPrint('Failed to create fallback AuthBloc: $e2');
                    return true;
                  }());
                  rethrow;
                }
              }
            },
          ),
          BlocProvider(
            create: (context) {
              try {
                return getIt<ActivityBloc>();
              } catch (e, stackTrace) {
                // Return a basic ActivityBloc if DI fails (silent in production)
                assert(() {
                  debugPrint('Error creating ActivityBloc: $e');
                  debugPrint('Stack: $stackTrace');
                  return true;
                }());
                try {
                  return ActivityBloc(
                    getIt(),
                    getIt(),
                    getIt(),
                    getIt(),
                    getIt(),
                  );
                } catch (e2) {
                  assert(() {
                    debugPrint('Failed to create fallback ActivityBloc: $e2');
                    return true;
                  }());
                  rethrow;
                }
              }
            },
          ),
        ],
        child: MaterialApp(
          title: 'FitQuest',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeService.themeMode,
          onGenerateRoute: AppRouter.generateRoute,
          initialRoute: AppRouter.splash,
          builder: (context, child) {
            // Add error boundary
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child ?? const SizedBox.shrink(),
            );
          },
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error building FitQuestApp: $e');
      debugPrint('Stack: $stackTrace');
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'App Error',
                      style: GoogleFonts.fredoka(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Error: $e',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Try to restart the app
                        runApp(const FitQuestApp());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
