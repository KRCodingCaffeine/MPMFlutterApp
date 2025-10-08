import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/EventTripModel/DeleteTraveller/DeleteTravellerModelClass.dart';
import 'package:mpm/utils/urls.dart';

class DeleteTravellerRepository {
  final api = NetWorkApiService();

  Future<DeleteTravellerModelClass> deleteTraveller(String tripTravellerId) async {
    try {
      final requestBody = {
        'trip_traveller_id': tripTravellerId,
      };

      final response = await api.postApi(
        requestBody,
        Urls.delete_traveller_url,
        "",
        "2",
      );

      debugPrint("Delete Traveller Response: $response");

      return DeleteTravellerModelClass.fromJson(response);
    } catch (e) {
      debugPrint("Error deleting traveller: $e");
      rethrow;
    }
  }
}
