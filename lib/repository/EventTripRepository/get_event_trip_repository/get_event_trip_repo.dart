import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/utils/urls.dart';

class EventTripRepository {
  final api = NetWorkApiService();

  Future<dynamic> fetchTrips(String zoneId) async {
    try {
      final url = "${Urls.tripList_url}?zone_id=$zoneId";
      final response = await api.getApi(url, "");
      debugPrint("Event Trips Response: $response");
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

