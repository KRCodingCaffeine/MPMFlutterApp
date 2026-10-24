import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/JobPortal/GetSavedJobs/GetSavedJobsModelClass.dart';
import 'package:mpm/utils/urls.dart';

class GetSavedJobsRepository {
  final api = NetWorkApiService();

  Future<GetSavedJobsModelClass> getSavedJobs(String memberId) async {
    try {
      final url = "${Urls.get_saved_jobs_url}?member_id=$memberId";

      debugPrint("🔵 Get Saved Jobs URL: $url");

      final response = await api.getApi(
        url,
        "",
      );

      debugPrint("🟢 Response: $response");

      return GetSavedJobsModelClass.fromJson(response);
    } catch (e) {
      // API returns 404 when the member has no saved jobs
      if (RegExp(r'"code"\s*:\s*404').hasMatch(e.toString())) {
        return GetSavedJobsModelClass(
          status: false,
          code: 404,
          message: "No saved jobs found.",
          data: [],
          totalCount: 0,
        );
      }

      debugPrint("❌ Get Saved Jobs Error: $e");
      rethrow;
    }
  }
}
