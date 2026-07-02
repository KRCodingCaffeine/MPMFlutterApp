import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/JobPortal/GetQualificationByMemberId/GetQualificationByMemberIdModelClass.dart';
import 'package:mpm/utils/urls.dart';

class GetQualificationByMemberIdRepository {
  final api = NetWorkApiService();

  Future<GetQualificationByMemberIdModelClass> getQualificationsByMemberId(
      String memberId) async {
    try {

      final url =
          "${Urls.get_qualifications_by_member_id_url}?member_id=$memberId";

      debugPrint("🔵 Get Qualifications API URL: $url");

      final response = await api.getApi(
        url,
        "",
      );

      debugPrint("🟢 Response: $response");

      return GetQualificationByMemberIdModelClass.fromJson(response);

    } catch (e) {
      debugPrint("❌ Error Fetching Qualifications: $e");
      rethrow;
    }
  }
}