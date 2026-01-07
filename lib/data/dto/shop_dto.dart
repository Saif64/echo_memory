/// Shop Data Transfer Objects for Echo Memory
/// Models for shop items, purchases, and chests

import 'package:equatable/equatable.dart';

/// Shop item types
enum ShopItemType {
  lives,
  gems,
  coins,
  chest,
  theme,
  powerUp,
  bundle,
}

/// Shop item DTO
class ShopItemDTO extends Equatable {
  final String id;
  final String name;
  final String description;
  final ShopItemType type;
  final int price;
  final String currency; // 'coins', 'gems', or 'real' (IAP)
  final int? quantity;
  final String? imageUrl;
  final bool isPopular;
  final bool isBestValue;
  final double? discountPercent;

  const ShopItemDTO({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.price,
    required this.currency,
    this.quantity,
    this.imageUrl,
    this.isPopular = false,
    this.isBestValue = false,
    this.discountPercent,
  });

  factory ShopItemDTO.fromJson(Map<String, dynamic> json) {
    return ShopItemDTO(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: _parseType(json['type']),
      price: json['price'] ?? 0,
      currency: json['currency'] ?? 'coins',
      quantity: json['quantity'],
      imageUrl: json['imageUrl'],
      isPopular: json['isPopular'] ?? false,
      isBestValue: json['isBestValue'] ?? false,
      discountPercent: json['discountPercent']?.toDouble(),
    );
  }

  static ShopItemType _parseType(String? type) {
    switch (type?.toLowerCase()) {
      case 'lives':
        return ShopItemType.lives;
      case 'gems':
        return ShopItemType.gems;
      case 'coins':
        return ShopItemType.coins;
      case 'chest':
        return ShopItemType.chest;
      case 'theme':
        return ShopItemType.theme;
      case 'power_up':
      case 'powerup':
        return ShopItemType.powerUp;
      case 'bundle':
        return ShopItemType.bundle;
      default:
        return ShopItemType.coins;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'type': type.name,
        'price': price,
        'currency': currency,
        'quantity': quantity,
        'imageUrl': imageUrl,
        'isPopular': isPopular,
        'isBestValue': isBestValue,
        'discountPercent': discountPercent,
      };

  /// Check if this is an IAP item
  bool get isIAP => currency == 'real';

  /// Get the original price if discounted
  int? get originalPrice {
    if (discountPercent == null || discountPercent == 0) return null;
    return (price / (1 - discountPercent! / 100)).round();
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        price,
        currency,
        quantity,
        imageUrl,
        isPopular,
        isBestValue,
        discountPercent,
      ];
}

/// Purchase request
class PurchaseRequest {
  final String itemId;

  const PurchaseRequest({required this.itemId});

  Map<String, dynamic> toJson() => {'itemId': itemId};
}

/// Purchase response
class PurchaseResponseDTO extends Equatable {
  final bool success;
  final String itemId;
  final int newCoinsBalance;
  final int newGemsBalance;
  final String? unlockedContent;

  const PurchaseResponseDTO({
    required this.success,
    required this.itemId,
    required this.newCoinsBalance,
    required this.newGemsBalance,
    this.unlockedContent,
  });

  factory PurchaseResponseDTO.fromJson(Map<String, dynamic> json) {
    return PurchaseResponseDTO(
      success: json['success'] ?? false,
      itemId: json['itemId'] ?? '',
      newCoinsBalance: json['newCoinsBalance'] ?? 0,
      newGemsBalance: json['newGemsBalance'] ?? 0,
      unlockedContent: json['unlockedContent'],
    );
  }

  @override
  List<Object?> get props => [
        success,
        itemId,
        newCoinsBalance,
        newGemsBalance,
        unlockedContent,
      ];
}

/// Chest types
enum ChestType {
  wooden,
  silver,
  gold,
  legendary,
}

/// Open chest request
class OpenChestRequest {
  final String chestId;

  const OpenChestRequest({required this.chestId});

  Map<String, dynamic> toJson() => {'chestId': chestId};
}

/// Reward item from chest
class RewardItemDTO extends Equatable {
  final String type; // 'coins', 'gems', 'theme', 'power_up', etc.
  final int quantity;
  final String? itemId;
  final String? name;
  final String rarity; // 'common', 'rare', 'epic', 'legendary'

  const RewardItemDTO({
    required this.type,
    required this.quantity,
    this.itemId,
    this.name,
    this.rarity = 'common',
  });

  factory RewardItemDTO.fromJson(Map<String, dynamic> json) {
    return RewardItemDTO(
      type: json['type'] ?? 'coins',
      quantity: json['quantity'] ?? 0,
      itemId: json['itemId'],
      name: json['name'],
      rarity: json['rarity'] ?? 'common',
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'quantity': quantity,
        'itemId': itemId,
        'name': name,
        'rarity': rarity,
      };

  @override
  List<Object?> get props => [type, quantity, itemId, name, rarity];
}

/// Chest opening result
class ChestRewardDTO extends Equatable {
  final List<RewardItemDTO> rewards;
  final int totalCoins;
  final int totalGems;

  const ChestRewardDTO({
    required this.rewards,
    required this.totalCoins,
    required this.totalGems,
  });

  factory ChestRewardDTO.fromJson(Map<String, dynamic> json) {
    return ChestRewardDTO(
      rewards: (json['rewards'] as List<dynamic>?)
              ?.map((e) => RewardItemDTO.fromJson(e))
              .toList() ??
          [],
      totalCoins: json['totalCoins'] ?? 0,
      totalGems: json['totalGems'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [rewards, totalCoins, totalGems];
}
