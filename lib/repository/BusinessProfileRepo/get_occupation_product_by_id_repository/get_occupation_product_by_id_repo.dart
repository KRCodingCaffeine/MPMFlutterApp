import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/BusinessProfile/GetAllOccupationProduct/GetAllOccupationProductModelClass.dart';
import 'package:mpm/utils/urls.dart';

class OccupationProductRepository {
  final api = NetWorkApiService();

  Future<GetAllOccupationProductsModelClass> getAllProducts({
    required String profileId,
    String? categoryId,
    String? type,
    String? status,
    String? isFeatured,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final url =
          "${Urls.get_all_occupation_products_url}"
          "?member_business_occupation_profile_id=$profileId";

      debugPrint("🔵 GET All Products URL: $url");

      final response = await api.getApi(url, "");

      debugPrint("🟢 GET All Products RES: $response");

      return GetAllOccupationProductsModelClass.fromJson(response);

    } catch (e) {
      debugPrint("❌ Error fetching products: $e");
      rethrow;
    }
  }
}
