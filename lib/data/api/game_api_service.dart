/// Game API Service for Echo Memory
/// Handles game session start/end API calls

import '../dto/game_dto.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_config.dart';
import '../../core/network/api_response.dart';

class GameApiService {
  final ApiClient _apiClient;

  GameApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Start a new game session
  Future<ApiResponse<StartGameResponseDTO>> startGame({
    required String gameMode,
    String? difficulty,
  }) async {
    return await _apiClient.post(
      ApiConfig.gameStart,
      data: StartGameRequest(
        gameMode: gameMode,
        difficulty: difficulty,
      ).toJson(),
      fromJson: (json) => StartGameResponseDTO.fromJson(json),
    );
  }

  /// End a game session with results
  Future<ApiResponse<EndGameResponseDTO>> endGame({
    required String gameMode,
    required int score,
    required int level,
    required int streak,
    required int durationSeconds,
    List<String> powerUpsUsed = const [],
  }) async {
    return await _apiClient.post(
      ApiConfig.gameEnd,
      data: EndGameRequest(
        gameMode: gameMode,
        score: score,
        level: level,
        streak: streak,
        durationSeconds: durationSeconds,
        powerUpsUsed: powerUpsUsed,
      ).toJson(),
      fromJson: (json) => EndGameResponseDTO.fromJson(json),
    );
  }
}
