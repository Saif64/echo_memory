/// Economy API Service for Echo Memory
/// Handles coins, gems, lives, and daily bonus API calls

import '../dto/economy_dto.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_config.dart';
import '../../core/network/api_response.dart';

class EconomyApiService {
  final ApiClient _apiClient;

  EconomyApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get current economy state (coins, gems, lives)
  Future<ApiResponse<EconomyStateDTO>> getState() async {
    return await _apiClient.get(
      ApiConfig.economyState,
      fromJson: (json) => EconomyStateDTO.fromJson(json),
    );
  }

  /// Use a life to start a game
  Future<ApiResponse<EconomyStateDTO>> useLife(String gameMode) async {
    return await _apiClient.post(
      ApiConfig.economyUseLife,
      data: UseLifeRequest(gameMode: gameMode).toJson(),
      fromJson: (json) => EconomyStateDTO.fromJson(json),
    );
  }

  /// Buy lives with coins or gems
  Future<ApiResponse<EconomyStateDTO>> buyLives({
    required int quantity,
    required String currency,
  }) async {
    return await _apiClient.post(
      ApiConfig.economyBuyLives,
      data: BuyLivesRequest(
        quantity: quantity,
        currency: currency,
      ).toJson(),
      fromJson: (json) => EconomyStateDTO.fromJson(json),
    );
  }

  /// Claim daily bonus
  Future<ApiResponse<DailyBonusClaimDTO>> claimDailyBonus() async {
    return await _apiClient.post(
      ApiConfig.economyClaimDaily,
      fromJson: (json) => DailyBonusClaimDTO.fromJson(json),
    );
  }
}
