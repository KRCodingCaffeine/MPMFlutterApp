import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/utils/urls.dart';

class PartnerLogoRepository {
  final api = NetWorkApiService();

  // Update partner logo via POST request
  Future<dynamic> updatePartnerLogo(Map<String, dynamic> logoData) async {
    try {
      final response = await api.postApi(
        logoData,
        Urls.partner_logo, // Replace with actual URL key
        "",
        "2",
      );
      debugPrint("Partner Logo Update Response: $response");
      return response;
    } catch (e) {
      debugPrint("Error updating partner logo: $e");
      rethrow;
    }
  }
}
