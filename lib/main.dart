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
  configureDependencies();

  GoogleFonts.pendingFonts([
    GoogleFonts.fredoka(),
    GoogleFonts.nunito(),
  ]);

  await FirebaseConfig.initialize();
  await getIt<ThemeService>().initialize();
  await getIt<LocalStorageService>().init();

  _initializeNonCriticalServices();
}

Future<void> _initializeCriticalServices() async {
  configureDependencies();

  GoogleFonts.pendingFonts([
    GoogleFonts.fredoka(),
    GoogleFonts.nunito(),
  ]);
}

void _initializeNonCriticalServices() {
  Future.microtask(() async {
    try {
      try {
        await Hive.initFlutter();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Hive initialization skipped: $e');
        }
      }

      try {
        final firestore = FirebaseFirestore.instance;
        firestore.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: AppConstants.firestoreCacheSizeBytes,
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Firestore persistence setup skipped: $e');
        }
      }

      try {
        final firestoreCacheService = getIt<FirestoreCacheService>();
        await firestoreCacheService.ensureCacheSizeLimit();
        firestoreCacheService.logCacheStats();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Firestore cache service initialization skipped: $e');
        }
      }

      await getIt<CacheService>().init();
      ImageCacheConfig.configure();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Non-critical service initialization error: $e');
      }
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (kDebugMode) {
      debugPrint('ErrorWidget caught: ${details.exception}');
      debugPrint('Library: ${details.library}');
      if (details.stack != null) {
        debugPrint('Stack: ${details.stack}');
      }
    }
    
    return const SizedBox.shrink();
  };
  
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      debugPrint('FlutterError suppressed: ${details.exception}');
    }
  };
  try {
    await _initializeCriticalServices();
  } catch (e, stackTrace) {
    // Log error but continue - app can still show splash screen
    assert(() {
      debugPrint('Critical initialization error: $e');
      debugPrint('Stack: $stackTrace');
      return true;
    }());
  }

  runApp(const FitQuestApp());
  
  _initializeApp().catchError((e, stackTrace) {
    assert(() {
      debugPrint('Background initialization error: $e');
      debugPrint('Stack: $stackTrace');
      return true;
    }());
  });
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
    _themeService.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
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
