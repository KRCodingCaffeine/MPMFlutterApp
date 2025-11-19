import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/ProductCategory/ProductCategoryModelClass.dart';
import 'package:mpm/utils/urls.dart';

class ProductCategoryRepository {
  final api = NetWorkApiService();

  Future<ProductCategoryModelClass> getAllProductCategories({
    String type = "product",
    String status = "1",
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final url =
          "${Urls.product_categories_url}"
          "?type=$type"
          "&status=$status"
          "&limit=$limit"
          "&offset=$offset";

      debugPrint("🔵 GET Product Categories URL: $url");

      final response = await api.getApi(url, "");

      debugPrint("🟢 GET Product Categories RES: $response");

      return ProductCategoryModelClass.fromJson(response);

    } catch (e) {
      debugPrint("❌ Error fetching categories: $e");
      rethrow;
    }
  }
}
