import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/UpdatePriceDistribution/UpdatePriceDistributionModelClass.dart';
import 'package:mpm/utils/urls.dart';

class UpdatePriceDistributionRepository {
  final api = NetWorkApiService();

  /// Update Price Distribution for a member
  Future<UpdatePriceDistributionModelClass> updatePriceDistribution(
      Map<String, dynamic> requestBody) async {
    try {
      final response = await api.postApi(
        requestBody,
        Urls.update_price_distribution_url,
        "",
        "2",
      );

      debugPrint("Update Price Distribution Response: $response");

      return UpdatePriceDistributionModelClass.fromJson(response);
    } catch (e) {
      debugPrint("Error updating price distribution: $e");
      rethrow;
    }
  }
}
