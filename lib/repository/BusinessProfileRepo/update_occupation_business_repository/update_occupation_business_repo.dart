import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/BusinessProfile/UpdateOccupationBusiness/UpdateOccupationBusinessModelClass.dart';
import 'package:mpm/utils/urls.dart';

class UpdateOccupationBusinessRepository {
  final api = NetWorkApiService();

  Future<UpdateOccupationBusinessModelClass> updateOccupationBusiness(
      Map<String, dynamic> body) async {
    try {
      final url = Urls.update_member_occupation_profile_url;

      debugPrint("🔵 Update Occupation Profile URL: $url");
      debugPrint("📤 Update Request Body: $body");

      final safeBody = _convertAllValuesToStrings(body);

      final response = await api.postApi(safeBody, url, "", "1");

      debugPrint("🟢 Update Response: $response");

      return UpdateOccupationBusinessModelClass.fromJson(response);

    } catch (e) {
      debugPrint("❌ Error Updating Business Profile: $e");
      rethrow;
    }
  }

  Map<String, dynamic> _convertAllValuesToStrings(Map<String, dynamic> body) {
    final safe = <String, dynamic>{};

    body.forEach((key, value) {
      safe[key] = value == null ? '' : value.toString();
    });

    return safe;
  }
}
