// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fitquest/core/theme/app_theme.dart';
import 'package:fitquest/core/navigation/app_router.dart';
import 'package:fitquest/firebase_options.dart';
import 'package:fitquest/core/di/injection.dart';
import 'package:fitquest/shared/services/local_storage_service.dart';
import 'package:fitquest/core/services/cache_service.dart';
import 'package:fitquest/features/authentication/bloc/auth_bloc.dart';
import 'package:fitquest/features/authentication/bloc/auth_event.dart';
import 'package:fitquest/features/activities/bloc/activity_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _initializeApp() async {
  // Initialize Hive (skip on web if it fails)
  try {
    await Hive.initFlutter();
    debugPrint('Hive initialized');
  } catch (e) {
    // Hive might not work on web, that's okay
    debugPrint('Hive initialization skipped: $e');
  }

  // Initialize Firebase
  debugPrint('Initializing Firebase...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('Firebase initialized');

  // Enable Firestore persistence for offline support
  try {
    final firestore = FirebaseFirestore.instance;
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    debugPrint('Firestore persistence enabled');
  } catch (e) {
    debugPrint('Firestore persistence setup skipped: $e');
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
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize first, then show app
  try {
    await _initializeApp();
    debugPrint('Initialization complete');
  } catch (e) {
    debugPrint('Initialization error: $e');
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
  ThemeMode _themeMode = ThemeMode.light; // Default to light mode

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    // Listen for theme changes periodically
    _listenForThemeChanges();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final darkMode = prefs.getBool('dark_mode');
      if (mounted) {
        setState(() {
          // Default to light mode if no preference is set
          _themeMode = darkMode == true ? ThemeMode.dark : ThemeMode.light;
        });
      }
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
      // Default to light mode on error
      if (mounted) {
        setState(() {
          _themeMode = ThemeMode.light;
        });
      }
    }
  }

  void _listenForThemeChanges() {
    // Check theme preference every 200ms when app is active for faster updates
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _loadThemeMode();
        _listenForThemeChanges();
      }
    });
  }

  // Method to trigger immediate theme reload (can be called from theme toggle)
  void reloadTheme() {
    _loadThemeMode();
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
                  return AuthBloc(getIt(), getIt());
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
                  return ActivityBloc(getIt(), getIt(), getIt(), getIt());
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
          themeMode: _themeMode,
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
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red,),
                    const SizedBox(height: 16),
                    const Text(
                      'App Error',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Error: $e',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
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
