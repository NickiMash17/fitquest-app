import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:fitquest/features/authentication/bloc/auth_event.dart';
import 'package:fitquest/features/authentication/bloc/auth_state.dart';
import 'package:fitquest/shared/repositories/user_repository.dart';
import 'package:fitquest/shared/models/user_model.dart';

/// Authentication BLoC
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final firebase_auth.FirebaseAuth _auth;
  final UserRepository _userRepository;
  final Logger _logger = Logger();

  AuthBloc(this._auth, this._userRepository) : super(const AuthInitial()) {
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
        _logger.w(
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
          // If reload succeeds, the token is valid
          await _loadUserData(user.uid);
        } on firebase_auth.FirebaseAuthException catch (e) {
          // Token is invalid/expired, sign out
          if (e.code == 'invalid-credential' ||
              e.code == 'user-token-expired') {
            _logger.w('User token expired or invalid, signing out');
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
      _logger.e('Error checking auth status', error: e, stackTrace: stackTrace);
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
        await _loadUserData(credential.user!.uid);
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      _logger.e('Sign in error', error: e);
      emit(AuthError(message: _getErrorMessage(e.code)));
    } catch (e, stackTrace) {
      _logger.e('Unexpected sign in error', error: e, stackTrace: stackTrace);
      emit(const AuthError(message: 'An unexpected error occurred'));
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
      _logger.e('Sign up error', error: e);
      emit(AuthError(message: _getErrorMessage(e.code)));
    } catch (e, stackTrace) {
      _logger.e('Unexpected sign up error', error: e, stackTrace: stackTrace);
      emit(const AuthError(message: 'An unexpected error occurred'));
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
      _logger.e('Sign out error', error: e, stackTrace: stackTrace);
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
      _logger.i('Password reset email sent');
    } catch (e, stackTrace) {
      _logger.e('Password reset error', error: e, stackTrace: stackTrace);
      emit(const AuthError(message: 'Failed to send password reset email'));
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
      _logger.e('Error loading user data', error: e, stackTrace: stackTrace);
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _loadUserData(String userId) async {
    // Helper method that dispatches an event (for use in event handlers)
    add(AuthLoadUserDataRequested(userId: userId));
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      case 'user-token-expired':
        return 'Your session has expired. Please sign in again.';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}
