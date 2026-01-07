/// Dio-based API Client for Echo Memory
/// Handles all HTTP requests with interceptors for auth, logging, and error handling

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_config.dart';
import 'api_exceptions.dart';
import 'api_response.dart';
import 'environment_config.dart';

/// Token storage keys
class TokenKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String tokenExpiry = 'token_expiry';
}

/// API Client singleton with Dio
class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  late final FlutterSecureStorage _secureStorage;

  // Track if we're currently refreshing token to avoid multiple refresh calls
  bool _isRefreshing = false;

  ApiClient._() {
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
    _initDio();
  }

  factory ApiClient() {
    _instance ??= ApiClient._();
    return _instance!;
  }

  /// Get the Dio instance for direct access if needed
  Dio get dio => _dio;

  /// Initialize Dio with configuration and interceptors
  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: EnvironmentConfig.apiUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {
          'Content-Type': ApiConfig.contentType,
          'Accept': ApiConfig.acceptHeader,
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      _authInterceptor(),
      _loggingInterceptor(),
      _errorInterceptor(),
    ]);
  }

  /// Reinitialize Dio (useful when environment changes)
  void reinitialize() {
    _dio.options.baseUrl = EnvironmentConfig.apiUrl;
  }

  /// Auth interceptor - adds JWT token to requests
  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Skip auth for public endpoints
        final publicPaths = [
          ApiConfig.authGuest,
          ApiConfig.authGoogle,
          ApiConfig.authLogin,
          ApiConfig.authRegister,
          ApiConfig.authRefresh,
          ApiConfig.config,
        ];

        final isPublic = publicPaths.any(
          (path) => options.path.contains(path),
        );

        if (!isPublic) {
          final token = await _secureStorage.read(key: TokenKeys.accessToken);
          if (token != null) {
            options.headers[ApiConfig.authorizationHeader] =
                '${ApiConfig.bearerPrefix}$token';
          }
        }

        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 - try to refresh token
        if (error.response?.statusCode == 401 && !_isRefreshing) {
          _isRefreshing = true;
          try {
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the original request
              final token = await _secureStorage.read(
                key: TokenKeys.accessToken,
              );
              error.requestOptions.headers[ApiConfig.authorizationHeader] =
                  '${ApiConfig.bearerPrefix}$token';

              final response = await _dio.fetch(error.requestOptions);
              _isRefreshing = false;
              return handler.resolve(response);
            }
          } catch (e) {
            debugPrint('Token refresh failed: $e');
          }
          _isRefreshing = false;
        }
        handler.next(error);
      },
    );
  }

  /// Logging interceptor for debug mode
  Interceptor _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (kDebugMode) {
          debugPrint('🌐 ${options.method} ${options.uri}');
          if (options.data != null) {
            debugPrint('📤 Body: ${options.data}');
          }
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint('✅ ${response.statusCode} ${response.requestOptions.uri}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          debugPrint('❌ ${error.response?.statusCode} ${error.requestOptions.uri}');
          debugPrint('   Error: ${error.message}');
        }
        handler.next(error);
      },
    );
  }

  /// Error interceptor - transforms Dio errors to typed exceptions
  Interceptor _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        handler.next(_transformError(error));
      },
    );
  }

  /// Transform DioException to typed ApiException
  DioException _transformError(DioException error) {
    ApiException apiException;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        apiException = const TimeoutException();
        break;
      case DioExceptionType.connectionError:
        apiException = const NetworkException();
        break;
      case DioExceptionType.badResponse:
        apiException = _parseServerError(error.response);
        break;
      default:
        apiException = UnknownApiException(originalError: error);
    }

    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: apiException,
    );
  }

  /// Parse server error response to typed exception
  ApiException _parseServerError(Response? response) {
    if (response == null) {
      return const UnknownApiException();
    }

    final statusCode = response.statusCode;
    final data = response.data;

    String? message;
    String? errorCode;

    if (data is Map<String, dynamic>) {
      message = data['message'] as String?;
      errorCode = data['error'] as String?;
    }

    // Map error codes to specific exceptions
    switch (errorCode) {
      case 'UNAUTHORIZED':
        return const UnauthorizedException();
      case 'NO_LIVES':
        return const NoLivesException();
      case 'PURCHASE_FAILED':
        return const PurchaseFailedException();
      case 'VERIFICATION_FAILED':
        return const IapVerificationException();
    }

    // Map status codes
    switch (statusCode) {
      case 400:
        return ValidationException(message: message ?? 'Validation failed');
      case 401:
        return const UnauthorizedException();
      case 403:
        return const ForbiddenException();
      case 404:
        return NotFoundException(message: message ?? 'Not found');
      default:
        return ServerException(
          message: message ?? 'Server error',
          errorCode: errorCode,
          statusCode: statusCode,
        );
    }
  }

  /// Refresh the access token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(
        key: TokenKeys.refreshToken,
      );
      if (refreshToken == null) return false;

      final response = await _dio.post(
        ApiConfig.authRefresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        await saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
          expiresIn: data['expiresIn'],
        );
        return true;
      }
    } catch (e) {
      debugPrint('Token refresh error: $e');
      await clearTokens();
    }
    return false;
  }

  // ============ Token Management ============

  /// Save tokens to secure storage
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    await _secureStorage.write(key: TokenKeys.accessToken, value: accessToken);
    await _secureStorage.write(key: TokenKeys.refreshToken, value: refreshToken);
    final expiry = DateTime.now().add(Duration(seconds: expiresIn));
    await _secureStorage.write(
      key: TokenKeys.tokenExpiry,
      value: expiry.toIso8601String(),
    );
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: TokenKeys.accessToken);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: TokenKeys.accessToken);
    return token != null;
  }

  /// Clear all tokens (logout)
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: TokenKeys.accessToken);
    await _secureStorage.delete(key: TokenKeys.refreshToken);
    await _secureStorage.delete(key: TokenKeys.tokenExpiry);
  }

  // ============ HTTP Methods ============

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw e.error ?? const UnknownApiException();
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw e.error ?? const UnknownApiException();
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw e.error ?? const UnknownApiException();
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(path);
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw e.error ?? const UnknownApiException();
    }
  }
}
