import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/utils/urls.dart';

class GetEventsByCoordinatorRepository {
  final api = NetWorkApiService();

  Future<dynamic> fetchCoordinatorEvents({
    required String memberId,
    required String zoneId,
  }) async {
    try {
      final url =
          "${Urls.get_events_by_coordinator}?member_id=$memberId&zone_id=$zoneId";

      final response = await api.getApi(url, "");

      debugPrint("Coordinator Events Response: $response");

      return response;
    } catch (e) {
      rethrow;
    }
  }
}