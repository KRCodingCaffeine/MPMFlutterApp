import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/JobPortal/UpdateMemberApplicationStatus/UpdateMemberApplicationStatusModelClass.dart';
import 'package:mpm/utils/urls.dart';

class UpdateMemberApplicationStatusRepository {
  final api = NetWorkApiService();

  Future<UpdateMemberApplicationStatusModelClass> updateMemberApplicationStatus(
      Map<String, dynamic> body) async {
    try {
      final url = Urls.update_member_application_status_url;

      debugPrint("🔵 Update Member Application Status API URL: $url");
      debugPrint("📤 Request Body: $body");

      final safeBody = _convertAllValuesToStrings(body);

      final response = await api.postApi(
        safeBody,
        url,
        "",
        "2", // x-www-form-urlencoded
      );

      debugPrint("🟢 Response: $response");

      return UpdateMemberApplicationStatusModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Error Updating Member Application Status: $e");
      rethrow;
    }
  }

  Map<String, dynamic> _convertAllValuesToStrings(Map<String, dynamic> body) {
    final safeBody = <String, dynamic>{};

    body.forEach((key, value) {
      safeBody[key] = value?.toString() ?? '';
    });

    return safeBody;
  }
}
