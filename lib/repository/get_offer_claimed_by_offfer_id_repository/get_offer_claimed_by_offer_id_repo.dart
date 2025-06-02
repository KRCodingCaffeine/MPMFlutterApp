import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/utils/urls.dart';

class MemberClaimOfferRepository {
  final NetWorkApiService _apiService = NetWorkApiService();

  // Fetch member claim offers by offer ID
  Future<dynamic> fetchMemberClaimOffersByOfferId(String offerId) async {
    try {
      final response = await _apiService.getApi(
          "${Urls.offerClaimedByOfferId}/$offerId",
          ""
      );
      debugPrint("Member Claim Offers by Offer ID Response: $response");
      return response;
    } catch (e) {
      debugPrint("Error fetching member claim offers by offer ID: $e");
      rethrow;
    }
  }
}