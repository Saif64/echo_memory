/// Daily Challenge API Service for Echo Memory
/// Handles daily challenge API calls

import '../dto/daily_challenge_dto.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_config.dart';
import '../../core/network/api_response.dart';

class DailyChallengeApiService {
  final ApiClient _apiClient;

  DailyChallengeApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get today's challenge
  Future<ApiResponse<DailyChallengeDTO>> getToday() async {
    return await _apiClient.get(
      ApiConfig.dailyToday,
      fromJson: (json) => DailyChallengeDTO.fromJson(json),
    );
  }

  /// Submit challenge completion
  Future<ApiResponse<CompleteChallengeResponseDTO>> complete({
    required int score,
    required int durationSeconds,
    List<String> powerUpsUsed = const [],
  }) async {
    return await _apiClient.post(
      ApiConfig.dailyComplete,
      data: CompleteChallengeRequest(
        score: score,
        durationSeconds: durationSeconds,
        powerUpsUsed: powerUpsUsed,
      ).toJson(),
      fromJson: (json) => CompleteChallengeResponseDTO.fromJson(json),
    );
  }

  /// Get current streak info
  Future<ApiResponse<StreakInfoDTO>> getStreak() async {
    return await _apiClient.get(
      ApiConfig.dailyStreak,
      fromJson: (json) => StreakInfoDTO.fromJson(json),
    );
  }
}
