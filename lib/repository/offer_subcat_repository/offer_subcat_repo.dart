import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/utils/urls.dart';

class OrganisationSubcategoryRepository {
  final api = NetWorkApiService();

  // Fetch subcategories by organisation category ID via POST
  Future<dynamic> fetchSubcategoriesByCategory(int categoryId) async {
    try {
      final data = {
        "organisation_category_id": categoryId.toString(),
      };
      final response = await api.postApi(
        data,
        Urls.offer_discount_subcategory_by_category,
        "",
        "2",
      );
      debugPrint("Organisation SubCategories Response: $response");
      return response;
    } catch (e) {
      debugPrint("Error fetching organisation subcategories: $e");
      rethrow;
    }
  }
}
