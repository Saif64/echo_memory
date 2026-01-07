/// Shop State for Echo Memory
/// Manages shop items and purchases state

import 'package:equatable/equatable.dart';
import '../../../data/dto/shop_dto.dart';

enum ShopStatus {
  initial,
  loading,
  loaded,
  purchasing,
  openingChest,
  error,
}

class ShopState extends Equatable {
  final ShopStatus status;
  final List<ShopItemDTO> items;
  final ChestRewardDTO? lastChestReward;
  final PurchaseResponseDTO? lastPurchase;
  final String? errorMessage;
  final String? purchasingItemId;

  const ShopState({
    this.status = ShopStatus.initial,
    this.items = const [],
    this.lastChestReward,
    this.lastPurchase,
    this.errorMessage,
    this.purchasingItemId,
  });

  /// Initial state
  const ShopState.initial() : this();

  /// Loading state
  const ShopState.loading() : this(status: ShopStatus.loading);

  bool get isLoading => status == ShopStatus.loading;
  bool get isLoaded => status == ShopStatus.loaded;
  bool get isPurchasing => status == ShopStatus.purchasing;
  bool get isOpeningChest => status == ShopStatus.openingChest;

  /// Get items by type
  List<ShopItemDTO> getItemsByType(ShopItemType type) {
    return items.where((item) => item.type == type).toList();
  }

  /// Get featured items
  List<ShopItemDTO> get featuredItems {
    return items.where((item) => item.isPopular || item.isBestValue).toList();
  }

  ShopState copyWith({
    ShopStatus? status,
    List<ShopItemDTO>? items,
    ChestRewardDTO? lastChestReward,
    PurchaseResponseDTO? lastPurchase,
    String? errorMessage,
    String? purchasingItemId,
  }) {
    return ShopState(
      status: status ?? this.status,
      items: items ?? this.items,
      lastChestReward: lastChestReward ?? this.lastChestReward,
      lastPurchase: lastPurchase ?? this.lastPurchase,
      errorMessage: errorMessage ?? this.errorMessage,
      purchasingItemId: purchasingItemId ?? this.purchasingItemId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        lastChestReward,
        lastPurchase,
        errorMessage,
        purchasingItemId,
      ];
}
