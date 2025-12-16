import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitquest/features/home/bloc/home_event.dart';
import 'package:fitquest/features/home/bloc/home_state.dart';
import 'package:fitquest/shared/repositories/user_repository.dart';
import 'package:fitquest/shared/repositories/challenge_repository.dart';
import 'package:fitquest/shared/repositories/activity_repository.dart';
import 'package:fitquest/shared/models/challenge_model.dart';
import 'package:fitquest/shared/models/activity_model.dart';
import 'package:fitquest/shared/models/user_model.dart';
import 'package:fitquest/core/services/error_handler_service.dart';
import 'package:fitquest/core/utils/secure_logger.dart';

/// Home BLoC
@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserRepository _userRepository;
  final ChallengeRepository _challengeRepository;
  final ActivityRepository _activityRepository;
  final FirebaseAuth _auth;
  final ErrorHandlerService _errorHandler;

  HomeBloc(
    this._userRepository,
    this._challengeRepository,
    this._activityRepository,
    this._auth,
    this._errorHandler,
  ) : super(const HomeInitial()) {
    on<HomeDataLoadRequested>(_onHomeDataLoadRequested);
    on<HomeDataRefreshRequested>(_onHomeDataRefreshRequested);
  }

  Future<void> _onHomeDataLoadRequested(
    HomeDataLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    await _loadHomeData(emit);
  }

  Future<void> _onHomeDataRefreshRequested(
    HomeDataRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    await _loadHomeData(emit);
  }

  Future<void> _loadHomeData(Emitter<HomeState> emit) async {
    try {
      final userId = _auth.currentUser?.uid;
      SecureLogger.d('Loading home data for user: $userId');
      if (userId == null) {
        SecureLogger.w('No authenticated user found');
        emit(const HomeError(message: 'User not authenticated'));
        return;
      }

      // Load user data with retry (in case of timing issues after signup)
      UserModel? user;
      for (int i = 0; i < 3; i++) {
        try {
          user = await _userRepository.getUserCached(userId);
          if (user != null) break;
          if (i < 2) {
            SecureLogger.d('User not found, retrying... (attempt ${i + 1}/3)');
            await Future.delayed(Duration(milliseconds: 500 * (i + 1)));
          }
        } catch (e) {
          SecureLogger.e('Error loading user (attempt ${i + 1}): $e');
          if (i == 2) rethrow;
        }
      }

      if (user == null) {
        SecureLogger.e('User not found after retries: $userId');
        emit(
          const HomeError(
            message: 'User not found. Please try signing in again.',
          ),
        );
        return;
      }

      SecureLogger.d('User loaded successfully: ${user.displayName}');

      // PARALLEL FETCHING: Load challenge and activities concurrently
      final results = await Future.wait(
        [
          // Load daily challenge
          _challengeRepository.getDailyChallenge().catchError((e) {
            SecureLogger.w(
                'Error loading challenge, continuing without it: $e');
            return null;
          }),
          // Load today's activities
          _activityRepository.getTodayActivities(userId).catchError((e) {
            SecureLogger.w(
              'Error loading today activities, continuing with empty list: $e',
            );
            return <ActivityModel>[];
          }),
        ],
        eagerError: false,
      );

      final challenge = results[0] as ChallengeModel?;
      final todayActivities = results[1] as List<ActivityModel>;

      final todayXp = todayActivities.fold<int>(
        0,
        (sum, activity) => sum + (activity.xpEarned),
      );

      emit(
        HomeLoaded(
          user: user,
          dailyChallenge: challenge,
          todayActivities: todayActivities,
          todayXp: todayXp,
        ),
      );
    } catch (e, stackTrace) {
      SecureLogger.e(
        'Error loading home data',
        error: e,
        stackTrace: stackTrace,
      );
      final message = _errorHandler.handleError(e, type: ErrorType.unknown);
      emit(HomeError(message: message));
    }
  }
}
