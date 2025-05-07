import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/utils/urls.dart';

class OrganisationCategoryRepository {
  final api = NetWorkApiService();

  // Fetch organization categories list
  Future<dynamic> fetchOrganisationCategories() async {
    try {
      final response = await api.getApi(Urls.offer_category_url, "");
      debugPrint("Organisation Categories Response: $response");
      return response;
    } catch (e) {
      debugPrint("Error fetching organisation categories: $e");
      rethrow;
    }
  }
}