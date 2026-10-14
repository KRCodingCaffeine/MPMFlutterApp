import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/JobPortal/GetPostedJobsAppliedMembers/GetPostedJobsAppliedMembersModelClass.dart';
import 'package:mpm/utils/urls.dart';

class GetPostedJobsAppliedMembersRepository {
  final api = NetWorkApiService();

  Future<GetPostedJobsAppliedMembersModelClass> getPostedJobsAppliedMembers(
    String memberId,
  ) async {
    try {
      String url =
          "${Urls.get_posted_jobs_applied_members_url}?member_id=$memberId";

      debugPrint(
        "🔵 Get Posted Jobs Applied Members API URL: $url",
      );

      final response = await api.getApi(
        url,
        "",
      );

      debugPrint(
        "🟢 Posted Jobs Applied Members Response: $response",
      );

      return GetPostedJobsAppliedMembersModelClass.fromJson(response);
    } catch (e) {
      debugPrint(
        "❌ Error Fetching Posted Jobs Applied Members: $e",
      );

      rethrow;
    }
  }
}
