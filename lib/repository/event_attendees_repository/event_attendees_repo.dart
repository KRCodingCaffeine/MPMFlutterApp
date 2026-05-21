import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/utils/urls.dart';

class EventAttendeesRepository {
  final api = NetWorkApiService();

  Future<dynamic> fetchEventAttendees(String eventId) async {
    try {
      final url =
          "${Urls.get_event_attendees_list}?event_id=$eventId";

      final response = await api.getApi(url, "");

      debugPrint("Event Attendees Response: $response");

      return response;
    } catch (e) {
      rethrow;
    }
  }
}