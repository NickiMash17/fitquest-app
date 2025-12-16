// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_analytics/firebase_analytics.dart' as _i398;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_crashlytics/firebase_crashlytics.dart' as _i141;
import 'package:fitquest/core/services/analytics_service.dart' as _i241;
import 'package:fitquest/core/services/cache_service.dart' as _i524;
import 'package:fitquest/core/services/connectivity_service.dart' as _i475;
import 'package:fitquest/core/services/error_handler_service.dart' as _i905;
import 'package:fitquest/core/services/firestore_cache_service.dart' as _i53;
import 'package:fitquest/features/activities/bloc/activity_bloc.dart' as _i556;
import 'package:fitquest/features/authentication/bloc/auth_bloc.dart' as _i1051;
import 'package:fitquest/features/home/bloc/home_bloc.dart' as _i753;
import 'package:fitquest/shared/repositories/activity_repository.dart' as _i248;
import 'package:fitquest/shared/repositories/challenge_repository.dart'
    as _i384;
import 'package:fitquest/shared/repositories/goal_repository.dart' as _i398;
import 'package:fitquest/shared/repositories/leaderboard_repository.dart'
    as _i601;
import 'package:fitquest/shared/repositories/user_repository.dart' as _i595;
import 'package:fitquest/shared/services/local_storage_service.dart' as _i405;
import 'package:fitquest/shared/services/plant_service.dart' as _i959;
import 'package:fitquest/shared/services/xp_calculator_service.dart' as _i947;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i524.CacheService>(() => _i524.CacheService());
    gh.lazySingleton<_i475.ConnectivityService>(
        () => _i475.ConnectivityService());
    gh.lazySingleton<_i405.LocalStorageService>(
        () => _i405.LocalStorageService());
    gh.lazySingleton<_i947.XpCalculatorService>(
        () => _i947.XpCalculatorService());
    gh.lazySingleton<_i959.PlantService>(
        () => _i959.PlantService(gh<_i947.XpCalculatorService>()));
    gh.lazySingleton<_i53.FirestoreCacheService>(
        () => _i53.FirestoreCacheService(gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i248.ActivityRepository>(
        () => _i248.ActivityRepository(gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i384.ChallengeRepository>(
        () => _i384.ChallengeRepository(gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i398.GoalRepository>(
        () => _i398.GoalRepository(gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i601.LeaderboardRepository>(
        () => _i601.LeaderboardRepository(gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i241.AnalyticsService>(
        () => _i241.AnalyticsService(gh<_i398.FirebaseAnalytics>()));
    gh.lazySingleton<_i905.ErrorHandlerService>(() => _i905.ErrorHandlerService(
          gh<_i141.FirebaseCrashlytics>(),
          gh<_i398.FirebaseAnalytics>(),
        ));
    gh.lazySingleton<_i595.UserRepository>(() => _i595.UserRepository(
          gh<_i974.FirebaseFirestore>(),
          gh<_i59.FirebaseAuth>(),
        ));
    gh.factory<_i1051.AuthBloc>(() => _i1051.AuthBloc(
          gh<_i59.FirebaseAuth>(),
          gh<_i595.UserRepository>(),
          gh<_i905.ErrorHandlerService>(),
        ));
    gh.factory<_i753.HomeBloc>(() => _i753.HomeBloc(
          gh<_i595.UserRepository>(),
          gh<_i384.ChallengeRepository>(),
          gh<_i248.ActivityRepository>(),
          gh<_i59.FirebaseAuth>(),
          gh<_i905.ErrorHandlerService>(),
        ));
    gh.factory<_i556.ActivityBloc>(() => _i556.ActivityBloc(
          gh<_i248.ActivityRepository>(),
          gh<_i595.UserRepository>(),
          gh<_i947.XpCalculatorService>(),
          gh<_i59.FirebaseAuth>(),
          gh<_i905.ErrorHandlerService>(),
        ));
    return this;
  }
}
