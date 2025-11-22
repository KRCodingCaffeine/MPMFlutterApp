import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/BusinessProfile/UpdateOccupationProduct/UpdateOccupationProductModelClass.dart';
import 'package:mpm/utils/urls.dart';

class UpdateOccupationProductRepository {
  final api = NetWorkApiService();

  Future<UpdateOccupationProductModelClass> updateOccupationProduct(
      Map<String, dynamic> body) async {
    try {
      final url = Urls.update_member_occupation_product_url;

      debugPrint("🔵 Update Occupation Product API URL: $url");
      debugPrint("📤 Update Body: $body");

      final response = await api.postApi(body, url, "", "1");

      debugPrint("🟢 Update Product Response: $response");

      return UpdateOccupationProductModelClass.fromJson(response);

    } catch (e) {
      debugPrint("❌ Error Updating Product: $e");
      rethrow;
    }
  }
}
