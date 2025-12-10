import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/BusinessProfile/SendBusinessProfile/SendBusinessProfileModelClass.dart';
import 'package:mpm/utils/urls.dart';

class SendBusinessProfileRepository {
  final api = NetWorkApiService();

  Future<SendBusinessProfileModelClass> sendBusinessProfile({
    required String memberId,
    required String requestMemberId,
  }) async {
    try {
      final url = Urls.send_business_profile_url;

      final body = {
        "member_id": memberId,
        "request_member_id": requestMemberId,
      };

      debugPrint("📤 Sending Body: $body");

      final response = await api.postApi(body, url, "", "2");

      return SendBusinessProfileModelClass.fromJson(response);

    } catch (e) {
      debugPrint("❌ Error Sending Business Profile: $e");
      rethrow;
    }
  }
}
