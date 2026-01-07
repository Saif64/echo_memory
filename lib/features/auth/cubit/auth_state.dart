/// Auth State for Echo Memory
/// Manages authentication state

import 'package:equatable/equatable.dart';
import '../../../data/dto/auth_dto.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserDTO? user;
  final String? errorMessage;
  final bool isLinking;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isLinking = false,
  });

  /// Initial state
  const AuthState.initial() : this();

  /// Loading state
  const AuthState.loading()
      : this(status: AuthStatus.loading);

  /// Authenticated state
  AuthState.authenticated(UserDTO user)
      : this(status: AuthStatus.authenticated, user: user);

  /// Unauthenticated state
  const AuthState.unauthenticated()
      : this(status: AuthStatus.unauthenticated);

  /// Error state
  AuthState.error(String message)
      : this(status: AuthStatus.error, errorMessage: message);

  /// Check if user is authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Check if user is a guest
  bool get isGuest => user?.isGuest ?? true;

  /// Check if loading
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    UserDTO? user,
    String? errorMessage,
    bool? isLinking,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isLinking: isLinking ?? this.isLinking,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, isLinking];
}
