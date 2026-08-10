import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/JobPortal/GetJobByMemberId/GetJobByMemberIdModelClass.dart';
import 'package:mpm/utils/urls.dart';

class GetJobByMemberIdRepository {
  final api = NetWorkApiService();

  Future<GetJobByMemberIdModelClass> getJobs(String memberId, {String? status}) async {
    try {
      String url =
          "${Urls.get_jobs_url}?member_id=$memberId";

      if (status != null && status.isNotEmpty) {
        url += "&status=$status";
      }

      debugPrint("🔵 Get Jobs API URL: $url");

      final response = await api.getApi(
        url,
        "",
      );

      debugPrint("🟢 Jobs Response: $response");

      return GetJobByMemberIdModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Error Fetching Jobs: $e");
      rethrow;
    }
  }
}