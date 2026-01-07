/// Shop Repository for Echo Memory
/// Shop items and purchase handling

import '../api/shop_api_service.dart';
import '../dto/shop_dto.dart';
import '../../core/network/api_exceptions.dart';

class ShopRepository {
  final ShopApiService _shopApiService;

  List<ShopItemDTO>? _cachedItems;
  DateTime? _lastFetchTime;

  // Cache duration
  static const cacheDuration = Duration(minutes: 10);

  ShopRepository({ShopApiService? shopApiService})
      : _shopApiService = shopApiService ?? ShopApiService();

  /// Get cached shop items
  List<ShopItemDTO>? get cachedItems => _cachedItems;

  /// Fetch all shop items
  Future<List<ShopItemDTO>> fetchItems({bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid() && _cachedItems != null) {
      return _cachedItems!;
    }

    final response = await _shopApiService.getItems();

    if (!response.success || response.data == null) {
      throw ServerException(
        message: response.message ?? 'Failed to fetch shop items',
        errorCode: response.error,
      );
    }

    _cachedItems = response.data!;
    _lastFetchTime = DateTime.now();
    return _cachedItems!;
  }

  /// Get items by type
  List<ShopItemDTO> getItemsByType(ShopItemType type) {
    if (_cachedItems == null) return [];
    return _cachedItems!.where((item) => item.type == type).toList();
  }

  /// Purchase an item
  Future<PurchaseResponseDTO> purchase(String itemId) async {
    final response = await _shopApiService.purchase(itemId);

    if (!response.success || response.data == null) {
      if (response.error == 'PURCHASE_FAILED') {
        throw const PurchaseFailedException();
      }
      throw ServerException(
        message: response.message ?? 'Purchase failed',
        errorCode: response.error,
      );
    }

    return response.data!;
  }

  /// Open a chest
  Future<ChestRewardDTO> openChest(String chestId) async {
    final response = await _shopApiService.openChest(chestId);

    if (!response.success || response.data == null) {
      throw ServerException(
        message: response.message ?? 'Failed to open chest',
        errorCode: response.error,
      );
    }

    return response.data!;
  }

  /// Check if cache is still valid
  bool _isCacheValid() {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < cacheDuration;
  }

  /// Clear cache
  void clearCache() {
    _cachedItems = null;
    _lastFetchTime = null;
  }

  /// Get featured/popular items
  List<ShopItemDTO> get featuredItems {
    if (_cachedItems == null) return [];
    return _cachedItems!
        .where((item) => item.isPopular || item.isBestValue)
        .toList();
  }

  /// Get chest items
  List<ShopItemDTO> get chestItems => getItemsByType(ShopItemType.chest);

  /// Get lives items
  List<ShopItemDTO> get livesItems => getItemsByType(ShopItemType.lives);

  /// Get gems items
  List<ShopItemDTO> get gemsItems => getItemsByType(ShopItemType.gems);
}
