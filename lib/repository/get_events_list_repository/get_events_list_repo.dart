import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/utils/urls.dart';

class EventRepository {
  final api = NetWorkApiService();

  // Fetch event list
  Future<dynamic> fetchEvents() async {
    try {
      final response = await api.getApi(Urls.eventList_url, "");
      debugPrint("Events Response: $response");
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
