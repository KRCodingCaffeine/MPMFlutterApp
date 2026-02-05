import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/BusinessProfile/ConnectedMember/ConnectedMemberModelClass.dart';
import 'package:mpm/utils/urls.dart';

class ConnectedMemberRepository {
  final api = NetWorkApiService();

  Future<ConnectedMemberModelClass> getConnectedMembers({
    required String requestedByMemberId,
  }) async {
    try {
      final url =
          "${Urls.get_member_business_connect_request_url}?business_connect_requested_by=$requestedByMemberId";

      debugPrint("📥 GET Connected Members URL: $url");

      final response = await api.getApi(url, "");

      return ConnectedMemberModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Error fetching connected members: $e");
      rethrow;
    }
  }
}
