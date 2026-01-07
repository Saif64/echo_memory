/// IAP API Service for Echo Memory
/// Handles in-app purchase verification API calls

import '../dto/iap_dto.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_config.dart';
import '../../core/network/api_response.dart';

class IapApiService {
  final ApiClient _apiClient;

  IapApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Verify a purchase receipt
  Future<ApiResponse<VerifyPurchaseResponseDTO>> verifyPurchase({
    required String store,
    required String productId,
    required String receipt,
    required String orderId,
  }) async {
    return await _apiClient.post(
      ApiConfig.iapVerify,
      data: VerifyPurchaseRequest(
        store: store,
        productId: productId,
        receipt: receipt,
        orderId: orderId,
      ).toJson(),
      fromJson: (json) => VerifyPurchaseResponseDTO.fromJson(json),
    );
  }

  /// Get available IAP products
  Future<ApiResponse<List<IapProductDTO>>> getProducts() async {
    return await _apiClient.get(
      ApiConfig.iapProducts,
      fromJson: (json) {
        if (json is List) {
          return json.map((e) => IapProductDTO.fromJson(e)).toList();
        }
        return <IapProductDTO>[];
      },
    );
  }
}
