import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/GetAllBusinessOccupationProfile/GetAllBusinessOccupationProfileModelClass.dart';
import 'package:mpm/utils/urls.dart';

class BusinessOccupationProfileRepository {
  final api = NetWorkApiService();

  Future<GetAllBusinessOccupationProfileModelClass> fetchBusinessOccupationProfiles({
    required String memberId,
    int limit = 50,
    int offset = 0,
    bool fullDetails = false,
  }) async {
    try {
      final url =
          "${Urls.get_all_business_occupation_profile_url}?member_id=$memberId&limit=$limit&offset=$offset&full_details=$fullDetails";

      debugPrint("🔵 Business Profile URL: $url");

      final response = await api.getApi(url, "");

      debugPrint("🟢 Business Profile RES: $response");

      return GetAllBusinessOccupationProfileModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Error fetching business occupation profile: $e");
      rethrow;
    }
  }
}
