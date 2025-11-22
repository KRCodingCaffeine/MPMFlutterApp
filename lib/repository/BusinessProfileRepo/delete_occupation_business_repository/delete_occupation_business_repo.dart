import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/BusinessProfile/DeleteOccupationBusiness/DeleteOccupationBusinessModelClass.dart';
import 'package:mpm/utils/urls.dart';

class DeleteOccupationBusinessRepository {
  final api = NetWorkApiService();

  Future<DeleteOccupationBusinessModelClass> deleteOccupationBusinessProfile(
      String businessOccupationProfileId) async {
    try {
      final url = Urls.delete_member_occupation_profile_url;

      debugPrint("🔵 Delete Occupation Business API URL: $url");

      // Try sending as raw JSON instead of form data
      final body = {
        "member_business_occupation_profile_id": businessOccupationProfileId,
      };

      debugPrint("📤 Delete Request Body: $body");

      // Try with type "1" for JSON instead of "2" for form data
      final response = await api.postApi(body, url, "", "1");

      debugPrint("🟢 Delete Occupation Business Response: $response");

      return DeleteOccupationBusinessModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Error Deleting Occupation Business: $e");
      rethrow;
    }
  }
}