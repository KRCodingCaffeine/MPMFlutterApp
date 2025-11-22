import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/BusinessProfile/BusinessOccupationProfile/BusinessOccupationProfileModelClass.dart';
import 'package:mpm/utils/urls.dart';

class BusinessOccupationProfileRepository {
  final api = NetWorkApiService();

  /// Fetch All Business Occupation Profiles
  Future<BusinessOccupationProfileModelClass> fetchBusinessOccupationProfiles({
    required String memberId,
    int limit = 50,
    int offset = 0,
    bool fullDetails = false,
  }) async {
    try {
      final url =
          "${Urls.business_occupation_profile_url}?member_id=$memberId&limit=$limit&offset=$offset&full_details=$fullDetails";

      debugPrint("🔵 Business Occupation Profile API URL: $url");

      final response = await api.getApi(url, "");

      return BusinessOccupationProfileModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Error Fetching Business Occupation Profiles: $e");
      rethrow;
    }
  }
}
