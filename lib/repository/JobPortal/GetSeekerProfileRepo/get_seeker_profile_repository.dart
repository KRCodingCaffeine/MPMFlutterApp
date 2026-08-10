import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/JobPortal/GetSeekerProfile/GetSeekerProfileModelClass.dart';
import 'package:mpm/utils/urls.dart';

class GetSeekerProfileRepository {
  final api = NetWorkApiService();

  Future<GetSeekerProfileModelClass> getSeekerProfile(
      String memberId) async {
    try {
      final url =
          "${Urls.get_seeker_profile_url}?member_id=$memberId";

      debugPrint("🔵 Get Seeker Profile URL: $url");

      final response = await api.getApi(
        url,
        "",
      );

      debugPrint("🟢 Response: $response");

      return GetSeekerProfileModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Error Get Seeker Profile: $e");
      rethrow;
    }
  }
}