import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/GetMemberRegisteredEvents/GetMemberRegisteredEventsModelClass.dart';
import 'package:mpm/utils/urls.dart';

class EventAttendeesRepository {
  final api = NetWorkApiService();

  /// Fetches all event attendees for a specific member ID
  Future<EventAttendeesModelClass> fetchEventAttendeesByMemberId(int memberId) async {
    try {
      final requestBody = {
        'member_id': memberId.toString(),
      };

      final response = await api.postApi(
        requestBody,
        Urls.event_attendees,
        "",
        "2",
      );

      debugPrint("Event Attendees Response: $response");

      return EventAttendeesModelClass.fromJson(response);
    } catch (e) {
      debugPrint("Error fetching event attendees: $e");
      rethrow;
    }
  }
}
