/// Authentication Repository for Echo Memory
/// Handles auth logic, token storage, and session management

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api/auth_api_service.dart';
import '../dto/auth_dto.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exceptions.dart';

class AuthRepository {
  final AuthApiService _authApiService;
  final ApiClient _apiClient;
  final GoogleSignIn _googleSignIn;

  UserDTO? _currentUser;

  AuthRepository({
    AuthApiService? authApiService,
    ApiClient? apiClient,
    GoogleSignIn? googleSignIn,
  })  : _authApiService = authApiService ?? AuthApiService(),
        _apiClient = apiClient ?? ApiClient(),
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email', 'profile'],
            );

  /// Get current user
  UserDTO? get currentUser => _currentUser;

  /// Check if user is authenticated
  Future<bool> get isAuthenticated async {
    return await _apiClient.isAuthenticated();
  }

  /// Check if current user is a guest
  bool get isGuest => _currentUser?.isGuest ?? true;

  /// Guest login
  Future<UserDTO> guestLogin({String? displayName}) async {
    final name = displayName ?? 'Player${DateTime.now().millisecondsSinceEpoch % 10000}';
    
    final response = await _authApiService.guestLogin(name);
    
    if (!response.success || response.data == null) {
      throw const ServerException(
        message: 'Failed to create guest account',
        errorCode: 'GUEST_CREATION_FAILED',
      );
    }

    await _handleLoginSuccess(response.data!);
    return _currentUser!;
  }

  /// Google Sign-In
  Future<UserDTO> googleLogin() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const ServerException(
          message: 'Google Sign-In cancelled',
          errorCode: 'GOOGLE_AUTH_CANCELLED',
        );
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw const ServerException(
          message: 'Failed to get Google ID token',
          errorCode: 'GOOGLE_AUTH_FAILED',
        );
      }

      final response = await _authApiService.googleLogin(
        idToken,
        displayName: googleUser.displayName,
      );

      if (!response.success || response.data == null) {
        throw const ServerException(
          message: 'Google authentication failed',
          errorCode: 'GOOGLE_AUTH_FAILED',
        );
      }

      await _handleLoginSuccess(response.data!);
      return _currentUser!;
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      if (e is ApiException) rethrow;
      throw const ServerException(
        message: 'Google authentication failed',
        errorCode: 'GOOGLE_AUTH_FAILED',
      );
    }
  }

  /// Email registration
  Future<UserDTO> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _authApiService.register(
      email: email,
      password: password,
      displayName: displayName,
    );

    if (!response.success || response.data == null) {
      throw ServerException(
        message: response.message ?? 'Registration failed',
        errorCode: response.error,
      );
    }

    await _handleLoginSuccess(response.data!);
    return _currentUser!;
  }

  /// Email login
  Future<UserDTO> login({
    required String email,
    required String password,
  }) async {
    final response = await _authApiService.login(
      email: email,
      password: password,
    );

    if (!response.success || response.data == null) {
      throw const ServerException(
        message: 'Invalid email or password',
        errorCode: 'INVALID_CREDENTIALS',
      );
    }

    await _handleLoginSuccess(response.data!);
    return _currentUser!;
  }

  /// Link guest account to Google
  Future<UserDTO> linkToGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const ServerException(
          message: 'Google Sign-In cancelled',
          errorCode: 'GOOGLE_AUTH_CANCELLED',
        );
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw const ServerException(
          message: 'Failed to get Google ID token',
          errorCode: 'GOOGLE_AUTH_FAILED',
        );
      }

      final response = await _authApiService.linkAccount(
        LinkAccountRequest(
          linkType: 'google',
          googleIdToken: idToken,
        ),
      );

      if (!response.success || response.data == null) {
        throw const ServerException(
          message: 'Failed to link account',
          errorCode: 'LINK_FAILED',
        );
      }

      await _handleLoginSuccess(response.data!);
      return _currentUser!;
    } catch (e) {
      debugPrint('Link to Google error: $e');
      if (e is ApiException) rethrow;
      throw const ServerException(
        message: 'Failed to link account',
        errorCode: 'LINK_FAILED',
      );
    }
  }

  /// Link guest account to email
  Future<UserDTO> linkToEmail({
    required String email,
    required String password,
  }) async {
    final response = await _authApiService.linkAccount(
      LinkAccountRequest(
        linkType: 'email',
        email: email,
        password: password,
      ),
    );

    if (!response.success || response.data == null) {
      throw ServerException(
        message: response.message ?? 'Failed to link account',
        errorCode: response.error ?? 'LINK_FAILED',
      );
    }

    await _handleLoginSuccess(response.data!);
    return _currentUser!;
  }

  /// Logout
  Future<void> logout() async {
    await _apiClient.clearTokens();
    await _googleSignIn.signOut();
    _currentUser = null;
  }

  /// Handle successful login
  Future<void> _handleLoginSuccess(LoginResponseDTO response) async {
    await _apiClient.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      expiresIn: response.expiresIn,
    );
    _currentUser = response.user;
  }

  /// Try to restore session from stored tokens
  Future<bool> tryRestoreSession() async {
    final hasToken = await _apiClient.isAuthenticated();
    // If we have a token, we consider ourselves logged in
    // The token refresh will happen automatically on first API call
    return hasToken;
  }
}
