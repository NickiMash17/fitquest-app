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
  ThemeMode _themeMode = ThemeMode.system;

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
      if (darkMode != null && mounted) {
        setState(() {
          _themeMode = darkMode ? ThemeMode.dark : ThemeMode.light;
        });
      }
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
    }
  }

  void _listenForThemeChanges() {
    // Check theme preference every 500ms when app is active
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadThemeMode();
        _listenForThemeChanges();
      }
    });
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
              } catch (e) {
                debugPrint('Error creating AuthBloc: $e');
                return AuthBloc(getIt(), getIt());
              }
            },
          ),
          BlocProvider(
            create: (context) {
              try {
                return getIt<ActivityBloc>();
              } catch (e) {
                debugPrint('Error creating ActivityBloc: $e');
                return ActivityBloc(getIt(), getIt(), getIt(), getIt());
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
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error building FitQuestApp: $e');
      debugPrint('Stack: $stackTrace');
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $e'),
              ],
            ),
          ),
        ),
      );
    }
  }
}
