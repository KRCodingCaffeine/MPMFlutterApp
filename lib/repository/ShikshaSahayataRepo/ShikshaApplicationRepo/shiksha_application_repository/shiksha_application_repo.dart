import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplication/GetShikshaApplicationModelClass.dart';
import 'package:mpm/utils/urls.dart';

class ShikshaApplicationRepository {
  final api = NetWorkApiService();

  /// Fetch Shiksha Application By Applicant ID
  Future<GetShikshaApplicationModelClass> fetchShikshaApplicationById({
    required String applicantId,
  }) async {
    try {
      final url =
          "${Urls.get_shiksha_application_by_id_url}?applicant_id=$applicantId";

      debugPrint("🔵 Shiksha Application URL: $url");

      final response = await api.getApi(url, "");

      debugPrint("🟢 Shiksha Application RES: $response");

      return GetShikshaApplicationModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Error fetching Shiksha Application: $e");
      rethrow;
    }
  }
}
