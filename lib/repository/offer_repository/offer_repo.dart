import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/utils/urls.dart';

class OfferRepository {
  var api = NetWorkApiService();
  // Fetch offer discount list
  Future<dynamic> fetchOfferDiscounts() async {
    try {
      final response = await api.getApi(Urls.offerdiscount_url, "");
      debugPrint("Offer Discounts Response: $response");
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
