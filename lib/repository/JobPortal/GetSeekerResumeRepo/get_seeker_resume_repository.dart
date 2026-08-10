import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/JobPortal/GetSeekerResume/GetSeekerResumeModelClass.dart';
import 'package:mpm/utils/urls.dart';

class GetSeekerResumeRepository {
  final api = NetWorkApiService();

  Future<GetSeekerResumeModelClass> getSeekerResume(String memberId) async {
    try {
      final url = "${Urls.get_seeker_resume_url}?member_id=$memberId";

      debugPrint("🔵 Get Resume URL: $url");

      final response = await api.getApi(
        url,
        "",
      );

      debugPrint("🟢 Response: $response");

      return GetSeekerResumeModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Get Resume Error: $e");
      rethrow;
    }
  }
}
