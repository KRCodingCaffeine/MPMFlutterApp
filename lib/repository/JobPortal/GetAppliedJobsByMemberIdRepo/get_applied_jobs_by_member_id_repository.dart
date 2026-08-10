import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/JobPortal/GetAppliedJobsByMemberId/GetAppliedJobsByMemberIdModelClass.dart';
import 'package:mpm/utils/urls.dart';

class GetAppliedJobsByMemberIdRepository {
  final api = NetWorkApiService();

  Future<GetAppliedJobsByMemberIdModelClass> getAppliedJobs(
      String memberId) async {
    try {
      final url =
          "${Urls.get_applied_jobs_url}?member_id=$memberId";

      debugPrint("🔵 Get Applied Jobs URL: $url");

      final response = await api.getApi(
        url,
        "",
      );

      debugPrint("🟢 Response: $response");

      return GetAppliedJobsByMemberIdModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Get Applied Jobs Error: $e");
      rethrow;
    }
  }
}