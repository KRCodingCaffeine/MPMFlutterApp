import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/BusinessProfile/DeleteOccupationProduct/DeleteOccupationProductModelClass.dart';
import 'package:mpm/utils/urls.dart';

class DeleteOccupationProductRepository {
  final api = NetWorkApiService();

  Future<DeleteOccupationProductModelClass> deleteProduct(String productServiceId) async {
    try {
      final url = Urls.delete_occupation_product_url;
      // Example: "/api/delete_member_occupation_product"

      debugPrint("🔵 Delete Product API URL: $url");

      final body = {
        "product_service_id": productServiceId,
      };

      debugPrint("📤 Delete Product Body: $body");

      // Use JSON request type = "1"
      final response = await api.postApi(body, url, "", "1");

      debugPrint("🟢 Delete Product Response: $response");

      return DeleteOccupationProductModelClass.fromJson(response);

    } catch (e) {
      debugPrint("❌ Error Deleting Product: $e");
      rethrow;
    }
  }
}
