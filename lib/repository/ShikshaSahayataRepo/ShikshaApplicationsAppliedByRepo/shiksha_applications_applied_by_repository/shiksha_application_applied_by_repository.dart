import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplicationsByAppliedBy/ShikshaApplicationsByAppliedByModelClass.dart';
import 'package:mpm/utils/urls.dart';

class ShikshaApplicationsByAppliedByRepository {
  final api = NetWorkApiService();

  /// Fetch Shiksha Applications By Applied By (Member ID)
  Future<ShikshaApplicationsByAppliedByModelClass>
  fetchShikshaApplicationsByAppliedBy({
    required String appliedBy,
  }) async {
    try {
      final url =
          "${Urls.get_shiksha_applications_by_applied_by}?applied_by=$appliedBy";

      debugPrint("🔵 Get Applications By AppliedBy URL: $url");

      final response = await api.getApi(url, "");

      debugPrint("🟢 Get Applications By AppliedBy RES: $response");

      return ShikshaApplicationsByAppliedByModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Error fetching applications by applied_by: $e");
      rethrow;
    }
  }
}
