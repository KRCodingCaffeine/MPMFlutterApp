import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/utils/urls.dart';

class AdminAccessRepository {
  final api = NetWorkApiService();

  Future<dynamic> fetchAdminAccess(String memberId) async {
    try {
      final url =
          "${Urls.get_admin_access_for_member}?member_id=$memberId";

      final response = await api.getApi(url, "");

      debugPrint("Admin Access Response: $response");

      return response;
    } catch (e) {
      rethrow;
    }
  }
}