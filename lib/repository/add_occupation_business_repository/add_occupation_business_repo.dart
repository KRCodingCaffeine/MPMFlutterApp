import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/AddOccupationBusiness/AddOccupationBusinessModelClass.dart';
import 'package:mpm/utils/urls.dart';

class AddOccupationBusinessRepository {
  final api = NetWorkApiService();

  Future<AddOccupationBusinessModelClass> addOccupationBusiness(
      Map<String, dynamic> body) async {
    try {
      final url = Urls.add_member_occupation_profile_url;

      debugPrint("🔵 Add Occupation Business API URL: $url");
      debugPrint("📤 Add Occupation Business Body: $body");

      // Convert all values to string to avoid JSON parsing issues
      final safeBody = _convertBodyToStrings(body);

      debugPrint("🔄 Safe Body: $safeBody");

      final response = await api.postApi(safeBody, url, "", "2");

      debugPrint("🟢 Add Occupation Business Response: $response");

      return AddOccupationBusinessModelClass.fromJson(response);

    } catch (e) {
      debugPrint("❌ Error Adding Occupation Business: $e");
      rethrow;
    }
  }

  // Helper method to convert all body values to strings
  Map<String, dynamic> _convertBodyToStrings(Map<String, dynamic> body) {
    final safeBody = <String, dynamic>{};

    body.forEach((key, value) {
      if (value == null) {
        safeBody[key] = '';
      } else if (value is num) {
        safeBody[key] = value.toString();
      } else if (value is bool) {
        safeBody[key] = value.toString();
      } else {
        safeBody[key] = value;
      }
    });

    return safeBody;
  }
}