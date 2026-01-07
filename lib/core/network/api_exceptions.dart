/// Custom API exceptions for Echo Memory
/// Typed exceptions for better error handling

/// Base exception for all API errors
abstract class ApiException implements Exception {
  final String message;
  final String? errorCode;
  final int? statusCode;
  final dynamic originalError;

  const ApiException({
    required this.message,
    this.errorCode,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'ApiException: $message (code: $errorCode)';
}

/// Network connectivity error
class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'No internet connection',
    super.originalError,
  });
}

/// Server returned an error response
class ServerException extends ApiException {
  const ServerException({
    required super.message,
    super.errorCode,
    super.statusCode,
    super.originalError,
  });
}

/// Authentication error (401)
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Unauthorized. Please login again.',
    super.errorCode = 'UNAUTHORIZED',
    super.statusCode = 401,
  });
}

/// Forbidden error (403)
class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'Access denied',
    super.errorCode = 'FORBIDDEN',
    super.statusCode = 403,
  });
}

/// Not found error (404)
class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'Resource not found',
    super.errorCode = 'NOT_FOUND',
    super.statusCode = 404,
  });
}

/// Validation error (400)
class ValidationException extends ApiException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    super.message = 'Validation failed',
    super.errorCode = 'VALIDATION_ERROR',
    super.statusCode = 400,
    this.fieldErrors,
  });
}

/// Request timeout
class TimeoutException extends ApiException {
  const TimeoutException({
    super.message = 'Request timed out. Please try again.',
    super.errorCode = 'TIMEOUT',
  });
}

/// Token refresh failed
class TokenRefreshException extends ApiException {
  const TokenRefreshException({
    super.message = 'Session expired. Please login again.',
    super.errorCode = 'TOKEN_REFRESH_FAILED',
  });
}

/// No lives available
class NoLivesException extends ApiException {
  const NoLivesException({
    super.message = 'No lives available',
    super.errorCode = 'NO_LIVES',
  });
}

/// Purchase failed
class PurchaseFailedException extends ApiException {
  const PurchaseFailedException({
    super.message = 'Purchase failed. Insufficient funds.',
    super.errorCode = 'PURCHASE_FAILED',
  });
}

/// IAP verification failed
class IapVerificationException extends ApiException {
  const IapVerificationException({
    super.message = 'Purchase verification failed',
    super.errorCode = 'VERIFICATION_FAILED',
  });
}

/// Unknown/generic error
class UnknownApiException extends ApiException {
  const UnknownApiException({
    super.message = 'An unexpected error occurred',
    super.originalError,
  });
}
