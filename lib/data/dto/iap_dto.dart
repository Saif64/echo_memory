/// IAP Data Transfer Objects for Echo Memory
/// Models for in-app purchase verification

import 'package:equatable/equatable.dart';

/// Store type
enum StoreType {
  google,
  apple,
}

/// IAP Product
class IapProductDTO extends Equatable {
  final String productId;
  final String name;
  final String description;
  final String price;
  final String currency;
  final int gems;
  final int? bonusGems;
  final bool isBestValue;

  const IapProductDTO({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.gems,
    this.bonusGems,
    this.isBestValue = false,
  });

  factory IapProductDTO.fromJson(Map<String, dynamic> json) {
    return IapProductDTO(
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? '0',
      currency: json['currency'] ?? 'USD',
      gems: json['gems'] ?? 0,
      bonusGems: json['bonusGems'],
      isBestValue: json['isBestValue'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'description': description,
        'price': price,
        'currency': currency,
        'gems': gems,
        'bonusGems': bonusGems,
        'isBestValue': isBestValue,
      };

  int get totalGems => gems + (bonusGems ?? 0);

  @override
  List<Object?> get props => [
        productId,
        name,
        description,
        price,
        currency,
        gems,
        bonusGems,
        isBestValue,
      ];
}

/// Verify purchase request
class VerifyPurchaseRequest {
  final String store; // 'google' or 'apple'
  final String productId;
  final String receipt;
  final String orderId;

  const VerifyPurchaseRequest({
    required this.store,
    required this.productId,
    required this.receipt,
    required this.orderId,
  });

  Map<String, dynamic> toJson() => {
        'store': store,
        'productId': productId,
        'receipt': receipt,
        'orderId': orderId,
      };
}

/// Verify purchase response
class VerifyPurchaseResponseDTO extends Equatable {
  final bool success;
  final bool verified;
  final int gemsAwarded;
  final int newGemsBalance;
  final String? transactionId;
  final String? errorMessage;

  const VerifyPurchaseResponseDTO({
    required this.success,
    required this.verified,
    required this.gemsAwarded,
    required this.newGemsBalance,
    this.transactionId,
    this.errorMessage,
  });

  factory VerifyPurchaseResponseDTO.fromJson(Map<String, dynamic> json) {
    return VerifyPurchaseResponseDTO(
      success: json['success'] ?? false,
      verified: json['verified'] ?? false,
      gemsAwarded: json['gemsAwarded'] ?? 0,
      newGemsBalance: json['newGemsBalance'] ?? 0,
      transactionId: json['transactionId'],
      errorMessage: json['errorMessage'],
    );
  }

  @override
  List<Object?> get props => [
        success,
        verified,
        gemsAwarded,
        newGemsBalance,
        transactionId,
        errorMessage,
      ];
}
