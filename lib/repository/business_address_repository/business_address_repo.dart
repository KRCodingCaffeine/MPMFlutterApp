import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/BusinessAddress/BusinessAddressModelClass.dart';
import 'package:mpm/utils/urls.dart';

class BusinessAddressRepository {
  final api = NetWorkApiService();

  /// Fetch All Business Addresses
  Future<BusinessAddressModelClass> fetchBusinessAddresses({
    required String businessProfileId,
  }) async {
    try {
      final url =
          "${Urls.business_address_url}?business_profile_id=$businessProfileId";

      debugPrint("🔵 Business Address API URL: $url");

      final response = await api.getApi(url, "");

      return BusinessAddressModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Error Fetching Business Addresses: $e");
      rethrow;
    }
  }
}
