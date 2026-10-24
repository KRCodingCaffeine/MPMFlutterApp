import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/JobPortal/GetListSeekerProfile/GetListSeekerProfilesModelClass.dart';
import 'package:mpm/utils/urls.dart';

class GetSeekerProfilesRepository {
  final api = NetWorkApiService();

  Future<GetListSeekerProfilesModelClass> getSeekerProfiles() async {
    try {
      final url = Urls.list_seeker_profiles_url;

      debugPrint("🔵 Get Seeker Profiles URL: $url");

      final response = await api.getApi(
        url,
        "",
      );

      debugPrint("🟢 Get Seeker Profiles Response: $response");

      return GetListSeekerProfilesModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Get Seeker Profiles Error: $e");
      rethrow;
    }
  }
}
