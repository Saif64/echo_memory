/// Config API Service for Echo Memory
/// Handles remote configuration API calls

import '../dto/config_dto.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_config.dart';
import '../../core/network/api_response.dart';

class ConfigApiService {
  final ApiClient _apiClient;

  ConfigApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get all remote config values
  Future<ApiResponse<RemoteConfigDTO>> getAllConfig() async {
    return await _apiClient.get(
      ApiConfig.config,
      fromJson: (json) => RemoteConfigDTO.fromJson(json),
    );
  }
}
