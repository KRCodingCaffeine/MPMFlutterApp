import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/utils/urls.dart';

class GetEventDetailByIdRepository {
  final api = NetWorkApiService();

  Future<dynamic> EventsDetailById(String eventId) async {
    try {
      final url = "${Urls.events_details_by_id_url}?event_id=$eventId";
      final response = await api.getApi(url, "");
      debugPrint("Events Response: $response");
      return response;
    } catch (e) { 
      rethrow;
    }
  }
}