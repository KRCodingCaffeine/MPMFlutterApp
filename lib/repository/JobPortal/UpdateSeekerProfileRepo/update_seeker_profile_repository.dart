import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/JobPortal/UpdateSeekerProfile/UpdateSeekerProfileModelClass.dart';
import 'package:mpm/utils/urls.dart';

class UpdateSeekerProfileRepository {
  final api = NetWorkApiService();

  Future<UpdateSeekerProfileModelClass> updateSeekerProfile(
      Map<String, dynamic> body) async {
    try {
      final url = Urls.update_seeker_profile_url;

      debugPrint("🔵 Update Seeker Profile API URL: $url");
      debugPrint("📤 Request Body: $body");

      final safeBody = _convertAllValuesToStrings(body);

      final response = await api.postApi(
        safeBody,
        url,
        "",
        "2", // x-www-form-urlencoded
      );

      debugPrint("🟢 Response: $response");

      return UpdateSeekerProfileModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Error Updating Seeker Profile: $e");
      rethrow;
    }
  }

  Map<String, dynamic> _convertAllValuesToStrings(
      Map<String, dynamic> body) {
    final safeBody = <String, dynamic>{};

    body.forEach((key, value) {
      safeBody[key] = value?.toString() ?? '';
    });

    return safeBody;
  }
}