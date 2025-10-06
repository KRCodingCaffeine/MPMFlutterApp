import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/EventTripModel/UpdateTraveller/UpdateTravellerModelClass.dart';
import 'package:mpm/utils/urls.dart';

class UpdateTravellerRepository {
  final api = NetWorkApiService();

  /// Update Traveller details for a trip
  Future<UpdateTravellerModelClass> updateTraveller(
      Map<String, dynamic> requestBody) async {
    try {
      final response = await api.postApi(
        requestBody,
        Urls.update_traveller_url,
        "",
        "2",
      );

      debugPrint("Update Traveller Response: $response");

      return UpdateTravellerModelClass.fromJson(response);
    } catch (e) {
      debugPrint("Error updating traveller: $e");
      rethrow;
    }
  }
}
