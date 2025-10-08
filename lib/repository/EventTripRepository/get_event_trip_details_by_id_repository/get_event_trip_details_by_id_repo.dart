import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/utils/urls.dart';

class GetEventTripDetailByIdRepository {
  final api = NetWorkApiService();

  Future<dynamic> EventTripDetailById(String tripId) async {
    try {
      final url = "${Urls.events_trip_details_by_id_url}?trip_id=$tripId";
      final response = await api.getApi(url, "");
      debugPrint("Event Trip Response: $response");
      return response;
    } catch (e) {
      rethrow;
    }
  }
}