import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/utils/urls.dart';

class EventRepository {
  final api = NetWorkApiService();

  Future<dynamic> fetchEvents(String zoneId) async {
    try {
      final url = "${Urls.eventList_url}?zone_id=$zoneId";
      final response = await api.getApi(url, "");
      debugPrint("Events Response: $response");
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

