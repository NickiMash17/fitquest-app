import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitquest/shared/repositories/user_repository.dart';
import 'package:fitquest/shared/repositories/activity_repository.dart';
import 'package:fitquest/shared/repositories/challenge_repository.dart';
import 'package:fitquest/shared/repositories/leaderboard_repository.dart';
import 'package:fitquest/shared/services/xp_calculator_service.dart';
import 'package:fitquest/shared/services/local_storage_service.dart';
import 'package:fitquest/core/services/cache_service.dart';
import 'package:fitquest/core/services/analytics_service.dart';
import 'package:fitquest/core/services/connectivity_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fitquest/features/authentication/bloc/auth_bloc.dart';
import 'package:fitquest/features/activities/bloc/activity_bloc.dart';
import 'package:fitquest/features/home/bloc/home_bloc.dart';

final getIt = GetIt.instance;

bool _isConfigured = false;

@InjectableInit()
void configureDependencies() {
  // Only configure once
  if (_isConfigured) {
    return;
  }
  
  // Register Firebase services
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton<FirebaseAnalytics>(() => FirebaseAnalytics.instance);
  
  // Register repositories
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(getIt(), getIt()),
  );
  getIt.registerLazySingleton<ActivityRepository>(
    () => ActivityRepository(getIt()),
  );
  getIt.registerLazySingleton<ChallengeRepository>(
    () => ChallengeRepository(getIt()),
  );
  getIt.registerLazySingleton<LeaderboardRepository>(
    () => LeaderboardRepository(getIt()),
  );
  
  // Register services
  getIt.registerLazySingleton<LocalStorageService>(() => LocalStorageService());
  getIt.registerLazySingleton<XpCalculatorService>(() => XpCalculatorService());
  
  // Register cache service
  getIt.registerLazySingleton<CacheService>(() => CacheService());
  
  // Register analytics service
  getIt.registerLazySingleton<AnalyticsService>(
    () => AnalyticsService(getIt()),
  );
  
  // Register connectivity service
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  
  // Register BLoCs (factories - can be registered multiple times safely)
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(getIt(), getIt()),
  );
  getIt.registerFactory<ActivityBloc>(
    () => ActivityBloc(getIt(), getIt(), getIt(), getIt()),
  );
  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(
      getIt<UserRepository>(),
      getIt<ChallengeRepository>(),
      getIt<ActivityRepository>(),
      getIt<FirebaseAuth>(),
    ),
  );
  
  _isConfigured = true;
}

