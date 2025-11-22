import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/BusinessProfile/AddOccupationBusiness/AddOccupationBusinessModelClass.dart';
import 'package:mpm/utils/urls.dart';

class AddOccupationBusinessRepository {
  final api = NetWorkApiService();

  Future<AddOccupationBusinessModelClass> addOccupationBusiness(
      Map<String, dynamic> body) async {
    try {
      final url = Urls.add_member_occupation_profile_url;

      debugPrint("🔵 Add Occupation Business API URL: $url");
      debugPrint("📤 Add Occupation Business Body: $body");

      // Convert all values to proper types with explicit string conversion
      final safeBody = _convertAllValuesToStrings(body);

      debugPrint("🔄 Safe Body: $safeBody");

      // Use JSON format (type "1")
      final response = await api.postApi(safeBody, url, "", "1");

      debugPrint("🟢 Add Occupation Business Response: $response");

      return AddOccupationBusinessModelClass.fromJson(response);

    } catch (e) {
      debugPrint("❌ Error Adding Occupation Business: $e");
      rethrow;
    }
  }

  // Convert ALL values to strings to avoid validation errors
  Map<String, dynamic> _convertAllValuesToStrings(Map<String, dynamic> body) {
    final safeBody = <String, dynamic>{};

    body.forEach((key, value) {
      if (value == null) {
        safeBody[key] = '';
      } else {
        // Convert EVERYTHING to string to be safe
        safeBody[key] = value.toString();
      }
    });

    return safeBody;
  }
}