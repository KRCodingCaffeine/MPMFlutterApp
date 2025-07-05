import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/DashBoardEvents/DashboardEventsModelClass.dart';
import 'package:mpm/utils/urls.dart';

class DashboardEventsRepository {
  final api = NetWorkApiService();

  Future<DashboardEventsModelClass> getDashboardEvents(int memberId) async {
    try {
      final requestBody = {'member_id': memberId.toString()};
      final response = await api.postApi(
        requestBody,
        Urls.get_dashboard_events_url,
        "",
        "2",
      );
      debugPrint("Dashboard Events Response: $response");
      return DashboardEventsModelClass.fromJson(response);
    } catch (e) {
      debugPrint("Error fetching dashboard events: $e");
      rethrow;
    }
  }
}
