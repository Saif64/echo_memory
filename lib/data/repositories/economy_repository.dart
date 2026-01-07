/// Economy Repository for Echo Memory
/// Manages economy state with caching and life regeneration

import 'dart:async';
import 'package:flutter/foundation.dart';

import '../api/economy_api_service.dart';
import '../dto/economy_dto.dart';
import '../../core/network/api_exceptions.dart';

class EconomyRepository {
  final EconomyApiService _economyApiService;

  EconomyStateDTO? _cachedState;
  Timer? _lifeRegenTimer;
  final _stateController = StreamController<EconomyStateDTO>.broadcast();

  EconomyRepository({EconomyApiService? economyApiService})
      : _economyApiService = economyApiService ?? EconomyApiService();

  /// Stream of economy state updates
  Stream<EconomyStateDTO> get stateStream => _stateController.stream;

  /// Get current cached state
  EconomyStateDTO? get currentState => _cachedState;

  /// Fetch economy state from server
  Future<EconomyStateDTO> fetchState() async {
    final response = await _economyApiService.getState();

    if (!response.success || response.data == null) {
      throw ServerException(
        message: response.message ?? 'Failed to fetch economy state',
      );
    }

    _cachedState = response.data!;
    _stateController.add(_cachedState!);
    _startLifeRegenTimer();
    return _cachedState!;
  }

  /// Use a life to start a game
  Future<EconomyStateDTO> useLife(String gameMode) async {
    if (_cachedState != null && _cachedState!.lives <= 0) {
      throw const NoLivesException();
    }

    final response = await _economyApiService.useLife(gameMode);

    if (!response.success || response.data == null) {
      if (response.error == 'NO_LIVES') {
        throw const NoLivesException();
      }
      throw ServerException(
        message: response.message ?? 'Failed to use life',
        errorCode: response.error,
      );
    }

    _cachedState = response.data!;
    _stateController.add(_cachedState!);
    _startLifeRegenTimer();
    return _cachedState!;
  }

  /// Buy lives with coins or gems
  Future<EconomyStateDTO> buyLives({
    required int quantity,
    required String currency,
  }) async {
    final response = await _economyApiService.buyLives(
      quantity: quantity,
      currency: currency,
    );

    if (!response.success || response.data == null) {
      if (response.error == 'PURCHASE_FAILED') {
        throw const PurchaseFailedException();
      }
      throw ServerException(
        message: response.message ?? 'Failed to buy lives',
        errorCode: response.error,
      );
    }

    _cachedState = response.data!;
    _stateController.add(_cachedState!);
    return _cachedState!;
  }

  /// Claim daily bonus
  Future<DailyBonusClaimDTO> claimDailyBonus() async {
    final response = await _economyApiService.claimDailyBonus();

    if (!response.success || response.data == null) {
      throw ServerException(
        message: response.message ?? 'Failed to claim daily bonus',
        errorCode: response.error,
      );
    }

    // Refresh state after claiming
    await fetchState();
    return response.data!;
  }

  /// Start timer to update life regeneration locally
  void _startLifeRegenTimer() {
    _lifeRegenTimer?.cancel();

    if (_cachedState == null || _cachedState!.hasFullLives) {
      return;
    }

    final timeUntilNext = _cachedState!.timeUntilNextLife;
    if (timeUntilNext == null || timeUntilNext.isNegative) {
      // Refresh from server
      fetchState();
      return;
    }

    _lifeRegenTimer = Timer(timeUntilNext, () {
      // Refresh from server when a life should regenerate
      fetchState();
    });
  }

  /// Update cached state with new values (for local optimistic updates)
  void updateLocalState({
    int? coins,
    int? gems,
    int? lives,
  }) {
    if (_cachedState == null) return;

    _cachedState = _cachedState!.copyWith(
      coins: coins,
      gems: gems,
      lives: lives,
    );
    _stateController.add(_cachedState!);
  }

  /// Check if daily bonus is available
  bool get isDailyBonusAvailable => _cachedState?.dailyBonusAvailable ?? false;

  /// Get current lives count
  int get lives => _cachedState?.lives ?? 0;

  /// Get current coins count
  int get coins => _cachedState?.coins ?? 0;

  /// Get current gems count
  int get gems => _cachedState?.gems ?? 0;

  /// Dispose resources
  void dispose() {
    _lifeRegenTimer?.cancel();
    _stateController.close();
  }
}
