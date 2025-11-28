import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/AddOccupation/AddOccupationModelClass.dart';
import 'package:mpm/utils/urls.dart';

class AddOccupationRepository {
  final api = NetWorkApiService();

  Future<AddOccupationModelClass> addOccupation(Map<String, dynamic> body) async {
    try {
      final url = Urls.add_occupation_url;

      debugPrint("🔵 Add Occupation API URL: $url");
      debugPrint("📤 Add Occupation Body: $body");

      final response = await api.postApi(body, url, "", "2");

      debugPrint("🟢 Add Occupation Response: $response");

      return AddOccupationModelClass.fromJson(response);

    } catch (e) {
      debugPrint("❌ Error Adding Occupation: $e");
      rethrow;
    }
  }
}
