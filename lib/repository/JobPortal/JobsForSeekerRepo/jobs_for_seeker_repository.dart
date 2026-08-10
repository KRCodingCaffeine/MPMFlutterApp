import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/JobPortal/JobsForSeekerJob/JobsForSeekerModelClass.dart';
import 'package:mpm/utils/urls.dart';

class JobsForSeekerRepository {
  final api = NetWorkApiService();

  Future<JobsForSeekerModelClass> getJobsForSeeker(
      String memberId) async {
    try {
      final url =
          "${Urls.jobs_for_seeker_url}?member_id=$memberId";

      debugPrint("🔵 Jobs For Seeker URL: $url");

      final response = await api.postApi(
        {
          "member_id": memberId,
        },
        Urls.jobs_for_seeker_url,
        "",
        "2",
      );

      debugPrint("🟢 Response: $response");

      return JobsForSeekerModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Error Jobs For Seeker: $e");
      rethrow;
    }
  }
}