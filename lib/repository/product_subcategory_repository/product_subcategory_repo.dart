import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/ProductSubcategory/ProductSubcategoryModelClass.dart';
import 'package:mpm/utils/urls.dart';

class ProductSubcategoryRepository {
  final api = NetWorkApiService();

  Future<ProductSubcategoryModelClass> getAllSubcategories({
    required String categoryId,
    String status = "1",
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final url =
          "${Urls.product_subcategories_url}"
          "?category_id=$categoryId"
          "&status=$status"
          "&limit=$limit"
          "&offset=$offset";

      debugPrint("🔵 GET Product Subcategories URL: $url");

      final response = await api.getApi(url, "");

      debugPrint("🟢 GET Product Subcategories Response: $response");

      return ProductSubcategoryModelClass.fromJson(response);

    } catch (e) {
      debugPrint("❌ Error fetching product subcategories: $e");
      rethrow;
    }
  }
}
