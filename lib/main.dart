// lib/main.dart
import 'dart:ui';
import 'package:flutter/material.dart';
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
  // Initialize Hive (skip on web if it fails)
  try {
    await Hive.initFlutter();
    debugPrint('Hive initialized');
  } catch (e) {
    // Hive might not work on web, that's okay
    debugPrint('Hive initialization skipped: $e');
  }

  // Initialize Firebase (includes Crashlytics)
  debugPrint('Initializing Firebase...');
  await FirebaseConfig.initialize();
  debugPrint('Firebase initialized');

  // Enable Firestore persistence for offline support with cache size limits
  try {
    final firestore = FirebaseFirestore.instance;
    firestore.settings = Settings(
      persistenceEnabled: true,
      cacheSizeBytes: AppConstants.firestoreCacheSizeBytes,
    );
    debugPrint(
        'Firestore persistence enabled with cache size: ${AppConstants.firestoreCacheSizeBytes ~/ (1024 * 1024)} MB');
  } catch (e) {
    debugPrint('Firestore persistence setup skipped: $e');
    // On some platforms (e.g., web), settings might not be configurable
    // This is okay - Firestore will use default settings
  }

  // Initialize Firestore cache service and ensure proper limits
  debugPrint('Initializing Firestore cache service...');
  try {
    final firestoreCacheService = getIt<FirestoreCacheService>();
    await firestoreCacheService.ensureCacheSizeLimit();
    firestoreCacheService.logCacheStats();
    debugPrint('Firestore cache service initialized');
  } catch (e) {
    debugPrint('Firestore cache service initialization skipped: $e');
  }

  // Initialize dependency injection
  debugPrint('Configuring dependencies...');
  configureDependencies();
  debugPrint('Dependencies configured');

  // Initialize local storage
  debugPrint('Initializing local storage...');
  await getIt<LocalStorageService>().init();
  debugPrint('Local storage initialized');

  // Initialize cache service
  debugPrint('Initializing cache service...');
  await getIt<CacheService>().init();
  debugPrint('Cache service initialized');

  // Initialize theme service
  debugPrint('Initializing theme service...');
  await getIt<ThemeService>().initialize();
  debugPrint('Theme service initialized');

  // Configure image cache
  debugPrint('Configuring image cache...');
  ImageCacheConfig.configure();
  debugPrint('Image cache configured');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Note: Error handlers are set up in FirebaseConfig.initialize()
  // They will be configured there to use Crashlytics

  // Initialize first, then show app
  try {
    await _initializeApp();
    debugPrint('Initialization complete');
  } catch (e, stackTrace) {
    debugPrint('Initialization error: $e');
    debugPrint('Stack: $stackTrace');
    // Continue anyway - app will show error if needed
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
                debugPrint('Error creating AuthBloc: $e');
                debugPrint('Stack: $stackTrace');
                // Return a basic AuthBloc if DI fails
                try {
                  return AuthBloc(getIt(), getIt(), getIt());
                } catch (e2) {
                  debugPrint('Failed to create fallback AuthBloc: $e2');
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
                debugPrint('Error creating ActivityBloc: $e');
                debugPrint('Stack: $stackTrace');
                // Return a basic ActivityBloc if DI fails
                try {
                  return ActivityBloc(getIt(), getIt(), getIt(), getIt(), getIt());
                } catch (e2) {
                  debugPrint('Failed to create fallback ActivityBloc: $e2');
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
