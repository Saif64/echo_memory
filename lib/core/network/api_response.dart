/// API Response wrapper for Echo Memory
/// Matches the backend's standard response format

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;
  final int? timestamp;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.timestamp,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      error: json['error'],
      timestamp: json['timestamp'],
    );
  }

  /// Check if response has data
  bool get hasData => data != null;

  /// Check if response has error
  bool get hasError => error != null || !success;

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, error: $error)';
  }
}
