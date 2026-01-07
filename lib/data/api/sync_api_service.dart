/// Sync API Service for Echo Memory
/// Handles cloud save push/pull API calls

import '../dto/sync_dto.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_config.dart';
import '../../core/network/api_response.dart';

class SyncApiService {
  final ApiClient _apiClient;

  SyncApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Pull server state (download cloud save)
  Future<ApiResponse<SyncPullResponseDTO>> pull() async {
    return await _apiClient.get(
      ApiConfig.syncPull,
      fromJson: (json) => SyncPullResponseDTO.fromJson(json),
    );
  }

  /// Push client state (upload to cloud)
  Future<ApiResponse<SyncPushResponseDTO>> push({
    required int totalGamesPlayed,
    required int totalScore,
    required int highScore,
    required int bestStreak,
    required int longestSequence,
    required int totalPlayTimeSeconds,
    required Map<String, int> modeHighScores,
  }) async {
    return await _apiClient.post(
      ApiConfig.syncPush,
      data: SyncPushRequest(
        totalGamesPlayed: totalGamesPlayed,
        totalScore: totalScore,
        highScore: highScore,
        bestStreak: bestStreak,
        longestSequence: longestSequence,
        totalPlayTimeSeconds: totalPlayTimeSeconds,
        modeHighScores: modeHighScores,
      ).toJson(),
      fromJson: (json) => SyncPushResponseDTO.fromJson(json),
    );
  }
}
