import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/BusinessProfile/AddBusinessConnectRequest/AddBusinessConnectRequestModelClass.dart';
import 'package:mpm/utils/urls.dart';
import 'dart:convert';

class AddBusinessConnectRequestRepository {
  final api = NetWorkApiService();

  Future<AddBusinessConnectRequestModelClass> sendBusinessConnectRequest({
    required String requestedByMemberId,
    required String requestedToMemberId,
    required String occupationId,
    required String createdBy,
  }) async {
    try {
      final url = Urls.add_member_business_connect_request_url;

      final body = {
        "business_connect_requested_by": requestedByMemberId,
        "business_connect_requested_to": requestedToMemberId,
        "business_connect_requested_occupation_id": occupationId,
        "business_connect_requested_status": "sent",
        "created_by": createdBy,
      };

      debugPrint("📤 Sending Business Connect Request: $body");

      final response = await api.postApi(
        body,
        url,
        "",
        "1",
      );

      return AddBusinessConnectRequestModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Error sending business connect request: $e");
      rethrow;
    }
  }
}
