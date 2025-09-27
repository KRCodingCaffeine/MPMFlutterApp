import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/GetEventAttendeesDetailById/GetEventAttendeesDetailByIdModelClass.dart';
import 'package:mpm/utils/urls.dart';

class GetEventAttendeesDetailByIdRepository {
  final api = NetWorkApiService();

  /// Fetch event attendee detail by attendee ID
  Future<GetEventAttendeesDetailByIdModelClass> fetchEventAttendeeDetailById(
      String eventAttendeesId) async {
    try {
      final requestBody = {
        'event_attendees_id': eventAttendeesId,
      };

      final response = await api.postApi(
        requestBody,
        Urls.get_event_attendees_detail_by_id,
        "",
        "2",
      );

      debugPrint("Event Attendee Detail Response: $response");

      return GetEventAttendeesDetailByIdModelClass.fromJson(response);
    } catch (e) {
      debugPrint("Error fetching event attendee detail: $e");
      rethrow;
    }
  }
}
