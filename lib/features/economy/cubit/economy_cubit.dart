/// Economy Cubit for Echo Memory
/// Manages coins, gems, lives, and daily bonus

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../data/repositories/economy_repository.dart';
import 'economy_state.dart';

class EconomyCubit extends Cubit<EconomyState> {
  final EconomyRepository _economyRepository;
  StreamSubscription? _stateSubscription;

  EconomyCubit({EconomyRepository? economyRepository})
      : _economyRepository = economyRepository ?? getIt<EconomyRepository>(),
        super(const EconomyState.initial()) {
    // Listen to repository state updates
    _stateSubscription = _economyRepository.stateStream.listen((economyState) {
      emit(EconomyState.loaded(economyState));
    });
  }

  /// Fetch current economy state from server
  Future<void> fetchState() async {
    emit(const EconomyState.loading());
    
    try {
      final economy = await _economyRepository.fetchState();
      emit(EconomyState.loaded(economy));
    } on ApiException catch (e) {
      emit(EconomyState.error(e.message));
    } catch (e) {
      emit(EconomyState.error('Failed to fetch economy state'));
    }
  }

  /// Use a life to start a game
  Future<bool> useLife(String gameMode) async {
    try {
      final economy = await _economyRepository.useLife(gameMode);
      emit(EconomyState.loaded(economy));
      return true;
    } on NoLivesException {
      emit(state.copyWith(errorMessage: 'No lives available'));
      return false;
    } on ApiException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
      return false;
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to use life'));
      return false;
    }
  }

  /// Buy lives with coins or gems
  Future<bool> buyLives({required int quantity, required String currency}) async {
    try {
      final economy = await _economyRepository.buyLives(
        quantity: quantity,
        currency: currency,
      );
      emit(EconomyState.loaded(economy));
      return true;
    } on PurchaseFailedException {
      emit(state.copyWith(errorMessage: 'Insufficient funds'));
      return false;
    } on ApiException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
      return false;
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to buy lives'));
      return false;
    }
  }

  /// Claim daily bonus
  Future<bool> claimDailyBonus() async {
    emit(state.copyWith(isDailyBonusClaiming: true));
    
    try {
      final bonus = await _economyRepository.claimDailyBonus();
      emit(state.copyWith(
        isDailyBonusClaiming: false,
        lastClaimedBonus: bonus,
      ));
      return true;
    } on ApiException catch (e) {
      emit(state.copyWith(
        isDailyBonusClaiming: false,
        errorMessage: e.message,
      ));
      return false;
    } catch (e) {
      emit(state.copyWith(
        isDailyBonusClaiming: false,
        errorMessage: 'Failed to claim daily bonus',
      ));
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  /// Clear last claimed bonus (after showing animation)
  void clearLastClaimedBonus() {
    emit(state.copyWith(lastClaimedBonus: null));
  }

  @override
  Future<void> close() {
    _stateSubscription?.cancel();
    return super.close();
  }
}
