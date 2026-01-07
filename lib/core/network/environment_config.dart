/// Environment/Flavor configuration for Echo Memory
/// Defines staging and production environments

enum Environment {
  staging,
  production,
}

class EnvironmentConfig {
  static Environment _environment = Environment.staging;

  /// Initialize the environment (call once at app startup)
  static void init(Environment env) {
    _environment = env;
  }

  /// Get current environment
  static Environment get current => _environment;

  /// Check if we're in staging
  static bool get isStaging => _environment == Environment.staging;

  /// Check if we're in production
  static bool get isProduction => _environment == Environment.production;

  /// Get the base URL for the current environment
  static String get baseUrl {
    switch (_environment) {
      case Environment.staging:
        return 'https://staging.dolfinmind.com';
      case Environment.production:
        return 'https://dolfinmind.com';
    }
  }

  /// API base path
  static String get apiBasePath => '/api/v1/echo-memory';

  /// Full API URL
  static String get apiUrl => '$baseUrl$apiBasePath';

  /// Environment name for display/logging
  static String get name {
    switch (_environment) {
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }
}
