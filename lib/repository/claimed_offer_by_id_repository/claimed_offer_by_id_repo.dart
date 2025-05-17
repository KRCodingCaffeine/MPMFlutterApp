import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/GetClaimedOfferByID/GetClaimedOfferByIDModelClass.dart';
import 'package:mpm/utils/urls.dart';

class ClaimOfferRepository {
  final api = NetWorkApiService();

  /// Fetches all claimed offers for a specific member ID
  Future<ClaimedOfferModel> fetchClaimedOffersByMemberId(int memberId) async {
    try {
      final requestBody = {
        'member_id': memberId.toString(),
      };

      final response = await api.postApi(
        requestBody,
        Urls.claimed_offer,
        "", // Empty header if not needed
        "2", // Version parameter
      );

      debugPrint("Claimed Offers Response: $response");

      return ClaimedOfferModel.fromJson(response);
    } catch (e) {
      debugPrint("Error fetching claimed offers: $e");
      rethrow;
    }
  }
}