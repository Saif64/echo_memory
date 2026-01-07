/// Auth Cubit for Echo Memory
/// Manages authentication state and actions

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({AuthRepository? authRepository})
      : _authRepository = authRepository ?? getIt<AuthRepository>(),
        super(const AuthState.initial());

  /// Check if user has existing session
  /// If no session exists, automatically login as guest
  Future<void> checkAuthStatus() async {
    emit(const AuthState.loading());
    
    try {
      final isAuthenticated = await _authRepository.isAuthenticated;
      
      if (isAuthenticated) {
        // User has token, consider them authenticated
        // Their user data will be fetched on first API call
        final user = _authRepository.currentUser;
        if (user != null) {
          emit(AuthState.authenticated(user));
        } else {
          // Has token but no user data cached - still try to use the session
          // Auto-login as guest if we can't restore the session
          await _autoGuestLogin();
        }
      } else {
        // No existing session - automatically login as guest
        await _autoGuestLogin();
      }
    } catch (e) {
      // On any error, try to login as guest
      await _autoGuestLogin();
    }
  }

  /// Automatically login as guest (used for first-time users)
  Future<void> _autoGuestLogin() async {
    try {
      final user = await _authRepository.guestLogin();
      emit(AuthState.authenticated(user));
    } catch (e) {
      // If even guest login fails, emit unauthenticated
      // This allows the app to still function in a degraded mode
      emit(const AuthState.unauthenticated());
    }
  }

  /// Guest login
  Future<void> guestLogin({String? displayName}) async {
    emit(const AuthState.loading());
    
    try {
      final user = await _authRepository.guestLogin(displayName: displayName);
      emit(AuthState.authenticated(user));
    } on ApiException catch (e) {
      emit(AuthState.error(e.message));
    } catch (e) {
      emit(AuthState.error('Failed to login as guest'));
    }
  }

  /// Google Sign-In
  Future<void> googleLogin() async {
    emit(const AuthState.loading());
    
    try {
      final user = await _authRepository.googleLogin();
      emit(AuthState.authenticated(user));
    } on ApiException catch (e) {
      emit(AuthState.error(e.message));
    } catch (e) {
      emit(AuthState.error('Google Sign-In failed'));
    }
  }

  /// Email registration
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    emit(const AuthState.loading());
    
    try {
      final user = await _authRepository.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      emit(AuthState.authenticated(user));
    } on ApiException catch (e) {
      emit(AuthState.error(e.message));
    } catch (e) {
      emit(AuthState.error('Registration failed'));
    }
  }

  /// Email login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthState.loading());
    
    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );
      emit(AuthState.authenticated(user));
    } on ApiException catch (e) {
      emit(AuthState.error(e.message));
    } catch (e) {
      emit(AuthState.error('Login failed'));
    }
  }

  /// Link guest account to Google
  Future<void> linkToGoogle() async {
    if (state.user == null) return;
    
    emit(state.copyWith(isLinking: true));
    
    try {
      final user = await _authRepository.linkToGoogle();
      emit(AuthState.authenticated(user));
    } on ApiException catch (e) {
      emit(state.copyWith(
        isLinking: false,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLinking: false,
        errorMessage: 'Failed to link account',
      ));
    }
  }

  /// Link guest account to email
  Future<void> linkToEmail({
    required String email,
    required String password,
  }) async {
    if (state.user == null) return;
    
    emit(state.copyWith(isLinking: true));
    
    try {
      final user = await _authRepository.linkToEmail(
        email: email,
        password: password,
      );
      emit(AuthState.authenticated(user));
    } on ApiException catch (e) {
      emit(state.copyWith(
        isLinking: false,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLinking: false,
        errorMessage: 'Failed to link account',
      ));
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } finally {
      emit(const AuthState.unauthenticated());
    }
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
