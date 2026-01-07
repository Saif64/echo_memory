/// Leaderboard API Service for Echo Memory
/// Handles leaderboard fetching API calls

import '../dto/leaderboard_dto.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_config.dart';
import '../../core/network/api_response.dart';

class LeaderboardApiService {
  final ApiClient _apiClient;

  LeaderboardApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get all-time leaderboard for a specific mode
  Future<ApiResponse<LeaderboardDTO>> getAllTime(String mode) async {
    return await _apiClient.get(
      ApiConfig.leaderboardMode(mode),
      fromJson: (json) => LeaderboardDTO.fromJson({
        ...json,
        'mode': mode,
        'period': 'all_time',
      }),
    );
  }

  /// Get weekly leaderboard for a specific mode
  Future<ApiResponse<LeaderboardDTO>> getWeekly(String mode) async {
    return await _apiClient.get(
      ApiConfig.leaderboardWeekly(mode),
      fromJson: (json) => LeaderboardDTO.fromJson({
        ...json,
        'mode': mode,
        'period': 'weekly',
      }),
    );
  }

  /// Get current user's ranks across all modes
  Future<ApiResponse<UserRanksDTO>> getUserRanks() async {
    return await _apiClient.get(
      ApiConfig.leaderboardMe,
      fromJson: (json) => UserRanksDTO.fromJson(json),
    );
  }
}
