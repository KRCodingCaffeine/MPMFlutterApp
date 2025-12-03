import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/utils/urls.dart';

class UpdateOccupationRepository {
  final api = NetWorkApiService();

  Future<bool> updateOccupation(Map<String, dynamic> body) async {
    try {
      final url = Urls.update_occupation_url;

      debugPrint("🔵 Update Occupation API URL: $url");
      debugPrint("📤 Update Occupation Body: $body");

      final response = await api.postApi(body, url, "", "2");

      debugPrint("🟢 Update Occupation API Response: $response");

      // ✅ Success condition
      if (response != null &&
          (response["status"] == true || response["status"] == "true") &&
          (response["code"] == 200 || response["code"] == "200")) {
        return true;
      }

      return false;

    } catch (e) {
      debugPrint("❌ Error Updating Occupation: $e");
      return false;
    }
  }
}
