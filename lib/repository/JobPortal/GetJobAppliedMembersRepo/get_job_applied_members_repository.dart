import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/JobPortal/GetJobAppliedMembers/GetJobAppliedMembersModelClass.dart';
import 'package:mpm/utils/urls.dart';

class GetJobAppliedMembersRepository {
  final api = NetWorkApiService();

  Future<GetJobAppliedMembersModelClass> getJobAppliedMembers(
      String jobId) async {
    try {
      final url =
          "${Urls.get_job_applied_members_url}?job_id=$jobId";

      debugPrint("🔵 Get Job Applied Members URL: $url");

      final response = await api.getApi(
        url,
        "",
      );

      debugPrint("🟢 Response: $response");

      return GetJobAppliedMembersModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Get Job Applied Members Error: $e");
      rethrow;
    }
  }
}