import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/BusinessProfile/AddOccupationProduct/AddOccupationProductModelClass.dart';
import 'package:mpm/utils/urls.dart';

class AddOccupationProductRepository {
  final api = NetWorkApiService();

  Future<AddOccupationProductModelClass> addOccupationProduct(
      Map<String, dynamic> body) async {
    try {
      final url = Urls.add_member_occupation_product_url;

      debugPrint("🔵 Add Occupation Product API URL: $url");
      debugPrint("📤 Raw Body Received: $body");

      final safeBody = _convertAllToStrings(body);

      debugPrint("🔄 Safe Converted Body: $safeBody");

      final response = await api.postApi(safeBody, url, "", "1");

      debugPrint("🟢 Add Occupation Product Response: $response");

      return AddOccupationProductModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Error Adding Product: $e");
      rethrow;
    }
  }

  /// Convert all values to strings to avoid validation errors
  Map<String, dynamic> _convertAllToStrings(Map<String, dynamic> input) {
    final Map<String, dynamic> output = {};
    input.forEach((key, value) {
      output[key] = value?.toString() ?? "";
    });
    return output;
  }
}
