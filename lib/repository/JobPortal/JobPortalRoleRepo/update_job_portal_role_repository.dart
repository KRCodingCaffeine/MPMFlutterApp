import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/JobPortal/JobPortalRole/UpdateJobPortalRoleModelClass.dart';
import 'package:mpm/utils/urls.dart';

class UpdateJobPortalRoleRepository {
  final api = NetWorkApiService();

  Future<UpdateJobPortalRoleModelClass> updateJobPortalRole(
      Map<String, dynamic> body) async {
    try {
      final url = Urls.update_job_portal_role_url;

      debugPrint("🔵 Update Job Portal Role API URL: $url");
      debugPrint("📤 Request Body: $body");

      final safeBody = _convertAllValuesToStrings(body);

      final response = await api.postApi(
        safeBody,
        url,
        "",
        "1",
      );

      debugPrint("🟢 Response: $response");

      return UpdateJobPortalRoleModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Error Updating Job Portal Role: $e");
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