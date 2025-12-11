import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:fitquest/features/authentication/bloc/auth_event.dart';
import 'package:fitquest/features/authentication/bloc/auth_state.dart';
import 'package:fitquest/shared/repositories/user_repository.dart';
import 'package:fitquest/shared/models/user_model.dart';
import 'package:fitquest/core/services/error_handler_service.dart';
import 'package:fitquest/core/utils/secure_logger.dart';
import 'package:fitquest/core/services/error_handler_service.dart' show ErrorType;

/// Authentication BLoC
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final firebase_auth.FirebaseAuth _auth;
  final UserRepository _userRepository;
  final ErrorHandlerService _errorHandler;

  AuthBloc(this._auth, this._userRepository, this._errorHandler)
      : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthLoadUserDataRequested>(_onLoadUserDataRequested);

    // Listen to auth state changes
    _auth.authStateChanges().listen(
      (user) {
        if (user != null) {
          // Only load if not already authenticated to avoid unnecessary calls
          if (state is! AuthAuthenticated) {
            add(AuthLoadUserDataRequested(userId: user.uid));
          }
        } else {
          if (state is! AuthUnauthenticated) {
            add(const AuthSignOutRequested());
          }
        }
      },
      onError: (error) {
        SecureLogger.w(
            'Auth state change error (likely expired token), signing out: $error',);
        // If there's an error (like invalid credentials), sign out gracefully
        if (state is! AuthUnauthenticated) {
          add(const AuthSignOutRequested());
        }
      },
    );
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      // Try to get the current user and reload their token
      final user = _auth.currentUser;
      if (user != null) {
        // Reload the user to refresh the token and check if it's still valid
        try {
          await user.reload();
          // If reload succeeds, the token is valid - load user data directly
          final userData = await _userRepository.getUser(user.uid);
          if (userData != null) {
            emit(AuthAuthenticated(user: userData));
          } else {
            emit(const AuthUnauthenticated());
          }
        } on firebase_auth.FirebaseAuthException catch (e) {
          // Token is invalid/expired, sign out
          if (e.code == 'invalid-credential' ||
              e.code == 'user-token-expired') {
            SecureLogger.w('User token expired or invalid, signing out');
            await _auth.signOut();
            emit(const AuthUnauthenticated());
          } else {
            rethrow;
          }
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e, stackTrace) {
      SecureLogger.e('Error checking auth status',
          error: e, stackTrace: stackTrace);
      // On any error, treat as unauthenticated
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      if (credential.user != null) {
        // Load user data directly instead of dispatching event
        final user = await _userRepository.getUser(credential.user!.uid);
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          // User document doesn't exist, create it
          final userModel = UserModel(
            id: credential.user!.uid,
            email: event.email,
            displayName: credential.user!.displayName ?? 'User',
            createdAt: DateTime.now(),
          );
          await _userRepository.createUser(userModel);
          emit(AuthAuthenticated(user: userModel));
        }
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      SecureLogger.e('Sign in error', error: e);
      final message = _errorHandler.handleFirebaseException(e);
      emit(AuthError(message: message));
    } catch (e, stackTrace) {
      SecureLogger.e('Unexpected sign in error',
          error: e, stackTrace: stackTrace);
      final message = _errorHandler.handleError(e, type: ErrorType.authentication);
      emit(AuthError(message: message));
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(event.displayName);

        // Create user document
        final userModel = UserModel(
          id: credential.user!.uid,
          email: event.email,
          displayName: event.displayName,
          createdAt: DateTime.now(),
        );
        await _userRepository.createUser(userModel);
        await _loadUserData(credential.user!.uid);
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      SecureLogger.e('Sign up error', error: e);
      final message = _errorHandler.handleFirebaseException(e);
      emit(AuthError(message: message));
    } catch (e, stackTrace) {
      SecureLogger.e('Unexpected sign up error',
          error: e, stackTrace: stackTrace);
      final message = _errorHandler.handleError(e, type: ErrorType.authentication);
      emit(AuthError(message: message));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _auth.signOut();
      emit(const AuthUnauthenticated());
    } catch (e, stackTrace) {
      SecureLogger.e('Sign out error', error: e, stackTrace: stackTrace);
      emit(const AuthUnauthenticated()); // Still sign out on error
    }
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _auth.sendPasswordResetEmail(email: event.email);
      // Don't change state, just log success
      SecureLogger.i('Password reset email sent');
    } catch (e, stackTrace) {
      SecureLogger.e('Password reset error', error: e, stackTrace: stackTrace);
      final message = _errorHandler.handleError(e, type: ErrorType.authentication);
      emit(AuthError(message: message));
    }
  }

  Future<void> _onLoadUserDataRequested(
    AuthLoadUserDataRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _userRepository.getUser(event.userId);
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e, stackTrace) {
      SecureLogger.e('Error loading user data',
          error: e, stackTrace: stackTrace);
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _loadUserData(String userId) async {
    // Helper method that dispatches an event (for use in event handlers)
    add(AuthLoadUserDataRequested(userId: userId));
  }

}
