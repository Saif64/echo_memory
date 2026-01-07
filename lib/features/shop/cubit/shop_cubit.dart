/// Shop Cubit for Echo Memory
/// Manages shop items and purchases

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../data/repositories/shop_repository.dart';
import 'shop_state.dart';

class ShopCubit extends Cubit<ShopState> {
  final ShopRepository _shopRepository;

  ShopCubit({ShopRepository? shopRepository})
      : _shopRepository = shopRepository ?? getIt<ShopRepository>(),
        super(const ShopState.initial());

  /// Load shop items
  Future<void> loadItems({bool forceRefresh = false}) async {
    emit(const ShopState.loading());

    try {
      final items = await _shopRepository.fetchItems(forceRefresh: forceRefresh);
      emit(state.copyWith(
        status: ShopStatus.loaded,
        items: items,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: ShopStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ShopStatus.error,
        errorMessage: 'Failed to load shop items',
      ));
    }
  }

  /// Purchase an item
  Future<bool> purchase(String itemId) async {
    emit(state.copyWith(
      status: ShopStatus.purchasing,
      purchasingItemId: itemId,
    ));

    try {
      final result = await _shopRepository.purchase(itemId);
      emit(state.copyWith(
        status: ShopStatus.loaded,
        lastPurchase: result,
        purchasingItemId: null,
      ));
      return true;
    } on PurchaseFailedException {
      emit(state.copyWith(
        status: ShopStatus.loaded,
        errorMessage: 'Insufficient funds',
        purchasingItemId: null,
      ));
      return false;
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: ShopStatus.loaded,
        errorMessage: e.message,
        purchasingItemId: null,
      ));
      return false;
    } catch (e) {
      emit(state.copyWith(
        status: ShopStatus.loaded,
        errorMessage: 'Purchase failed',
        purchasingItemId: null,
      ));
      return false;
    }
  }

  /// Open a chest
  Future<bool> openChest(String chestId) async {
    emit(state.copyWith(status: ShopStatus.openingChest));

    try {
      final result = await _shopRepository.openChest(chestId);
      emit(state.copyWith(
        status: ShopStatus.loaded,
        lastChestReward: result,
      ));
      return true;
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: ShopStatus.loaded,
        errorMessage: e.message,
      ));
      return false;
    } catch (e) {
      emit(state.copyWith(
        status: ShopStatus.loaded,
        errorMessage: 'Failed to open chest',
      ));
      return false;
    }
  }

  /// Clear last purchase
  void clearLastPurchase() {
    emit(state.copyWith(lastPurchase: null));
  }

  /// Clear last chest reward
  void clearLastChestReward() {
    emit(state.copyWith(lastChestReward: null));
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  /// Refresh shop items
  Future<void> refresh() async {
    await loadItems(forceRefresh: true);
  }
}
