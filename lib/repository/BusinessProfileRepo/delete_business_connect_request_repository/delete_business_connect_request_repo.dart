import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/BusinessProfile/DeleteBusinessConnectRequest/DeleteBusinessConnectRequestModelClass.dart';
import 'package:mpm/utils/urls.dart';

class DeleteBusinessConnectRequestRepository {
  final api = NetWorkApiService();

  Future<DeleteBusinessConnectRequestModelClass>
  deleteBusinessConnectRequest(String requestId) async {
    try {
      final url = Urls.delete_member_business_connect_request_url;

      debugPrint("🔵 Delete Business Connect API URL: $url");

      // RAW JSON body
      final body = {
        "member_business_connect_request_id": requestId,
      };

      debugPrint("📤 Delete Connect Request Body: $body");

      // TYPE "1" → RAW JSON (IMPORTANT)
      final response = await api.postApi(body, url, "", "1");

      debugPrint("🟢 Delete Business Connect Response: $response");

      return DeleteBusinessConnectRequestModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Error Deleting Business Connect Request: $e");
      rethrow;
    }
  }
}
