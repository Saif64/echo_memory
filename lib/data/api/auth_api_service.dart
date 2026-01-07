/// Authentication API Service for Echo Memory
/// Handles all auth-related API calls

import '../dto/auth_dto.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_config.dart';
import '../../core/network/api_response.dart';

class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Guest login
  Future<ApiResponse<LoginResponseDTO>> guestLogin(String displayName) async {
    return await _apiClient.post(
      ApiConfig.authGuest,
      data: GuestLoginRequest(displayName: displayName).toJson(),
      fromJson: (json) => LoginResponseDTO.fromJson(json),
    );
  }

  /// Google login
  Future<ApiResponse<LoginResponseDTO>> googleLogin(
    String idToken, {
    String? displayName,
  }) async {
    return await _apiClient.post(
      ApiConfig.authGoogle,
      data: GoogleLoginRequest(
        idToken: idToken,
        displayName: displayName,
      ).toJson(),
      fromJson: (json) => LoginResponseDTO.fromJson(json),
    );
  }

  /// Email registration
  Future<ApiResponse<LoginResponseDTO>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return await _apiClient.post(
      ApiConfig.authRegister,
      data: EmailRegisterRequest(
        email: email,
        password: password,
        displayName: displayName,
      ).toJson(),
      fromJson: (json) => LoginResponseDTO.fromJson(json),
    );
  }

  /// Email login
  Future<ApiResponse<LoginResponseDTO>> login({
    required String email,
    required String password,
  }) async {
    return await _apiClient.post(
      ApiConfig.authLogin,
      data: EmailLoginRequest(
        email: email,
        password: password,
      ).toJson(),
      fromJson: (json) => LoginResponseDTO.fromJson(json),
    );
  }

  /// Link guest account to permanent account
  Future<ApiResponse<LoginResponseDTO>> linkAccount(
    LinkAccountRequest request,
  ) async {
    return await _apiClient.post(
      ApiConfig.authLink,
      data: request.toJson(),
      fromJson: (json) => LoginResponseDTO.fromJson(json),
    );
  }

  /// Refresh tokens
  Future<ApiResponse<LoginResponseDTO>> refreshToken(
    String refreshToken,
  ) async {
    return await _apiClient.post(
      ApiConfig.authRefresh,
      data: RefreshTokenRequest(refreshToken: refreshToken).toJson(),
      fromJson: (json) => LoginResponseDTO.fromJson(json),
    );
  }
}
