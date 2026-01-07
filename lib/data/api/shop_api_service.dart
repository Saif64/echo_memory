/// Shop API Service for Echo Memory
/// Handles shop items and purchases API calls

import '../dto/shop_dto.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_config.dart';
import '../../core/network/api_response.dart';

class ShopApiService {
  final ApiClient _apiClient;

  ShopApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get all shop items
  Future<ApiResponse<List<ShopItemDTO>>> getItems() async {
    return await _apiClient.get(
      ApiConfig.shopItems,
      fromJson: (json) {
        if (json is List) {
          return json.map((e) => ShopItemDTO.fromJson(e)).toList();
        }
        return <ShopItemDTO>[];
      },
    );
  }

  /// Purchase an item
  Future<ApiResponse<PurchaseResponseDTO>> purchase(String itemId) async {
    return await _apiClient.post(
      ApiConfig.shopBuy,
      data: PurchaseRequest(itemId: itemId).toJson(),
      fromJson: (json) => PurchaseResponseDTO.fromJson(json),
    );
  }

  /// Open a chest
  Future<ApiResponse<ChestRewardDTO>> openChest(String chestId) async {
    return await _apiClient.post(
      ApiConfig.shopOpenChest,
      data: OpenChestRequest(chestId: chestId).toJson(),
      fromJson: (json) => ChestRewardDTO.fromJson(json),
    );
  }
}
