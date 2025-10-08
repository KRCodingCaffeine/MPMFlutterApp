import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/EventTripModel/TripMemberRegisteredDetailById/TripMemberRegisteredDetailByIdModelClass.dart';
import 'package:mpm/utils/urls.dart';

class TripMemberRegisteredDetailByIdRepository {
  final api = NetWorkApiService();

  /// Fetch registered trips for a member
  Future<TripMemberRegisteredDetailByIdModelCLass> fetchRegisteredTrips(String memberId) async {
    try {
      final requestBody = {
        'member_id': memberId,
      };

      final response = await api.postApi(
        requestBody,
        Urls.trip_member_registered_details_by_id_url,
        "",
        "2",
      );

      debugPrint("Registered Trips Response: $response");

      return TripMemberRegisteredDetailByIdModelCLass.fromJson(response);
    } catch (e) {
      debugPrint("Error fetching registered trips: $e");
      rethrow;
    }
  }
}
