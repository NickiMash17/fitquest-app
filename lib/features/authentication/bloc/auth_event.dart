import 'package:equatable/equatable.dart';

/// Authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check authentication status
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Sign in with email and password
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Sign up with email and password
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

/// Sign out
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Reset password
class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Load user data (internal event)
class AuthLoadUserDataRequested extends AuthEvent {
  final String userId;

  const AuthLoadUserDataRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}
