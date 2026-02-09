import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/ShikshaSahayata/ReferredMember/UpdateReferredMember/UpdateReferredMemberModelClass.dart';
import 'package:mpm/utils/urls.dart';

class UpdateReferredMemberRepository {
  final api = NetWorkApiService();

  Future<UpdateReferredMemberModelClass> updateReferredMember(
      Map<String, dynamic> body) async {
    try {
      final url = Urls.update_referred_member_url;

      debugPrint("🔵 Update Referred Member API URL: $url");
      debugPrint("📤 Request Body: $body");

      final safeBody = _convertAllValuesToStrings(body);

      final response = await api.postApi(
        safeBody,
        url,
        "",
        "1", // JSON type
      );

      debugPrint("🟢 Response: $response");

      return UpdateReferredMemberModelClass.fromJson(response);

    } catch (e) {
      debugPrint("❌ Error Updating Referred Member: $e");
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
