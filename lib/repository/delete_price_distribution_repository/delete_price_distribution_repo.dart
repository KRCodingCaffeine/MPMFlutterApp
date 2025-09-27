import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/DeletePriceDistribution/DeletePriceDistributionModelClass.dart';
import 'package:mpm/utils/urls.dart';

class DeletePriceDistributionRepository {
  final api = NetWorkApiService();

  Future<DeletePriceDistributionModelClass> deletePriceDistribution(eventAttendeesPriceMemberId) async {
    try {
      final requestBody = {
        'event_attendees_price_member_id': eventAttendeesPriceMemberId,
      };

      final response = await api.postApi(
        requestBody,
        Urls.delete_price_distribution_url,
        "",
        "2",
      );

      debugPrint("Delete Event Attendee Price Member Response: $response");

      return DeletePriceDistributionModelClass.fromJson(response);
    } catch (e) {
      debugPrint("Error deleting event attendee price member: $e");
      rethrow;
    }
  }
}
