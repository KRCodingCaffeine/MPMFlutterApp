import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/Getofferclaimedbyofferid/GetofferclaimedbyofferidData.dart';
import 'package:mpm/utils/urls.dart';

class MemberClaimOfferRepository {
  final _apiService = NetWorkApiService();

  Future<GetofferclaimedbyofferidData> fetchClaimedOfferByOfferId(
    String memberClaimOfferId,
  ) async {
    try {
      final requestBody = {
        'member_claim_offer_id': memberClaimOfferId,
      };

      final response = await _apiService.postApi(
        requestBody,
        Urls.offerClaimedByOfferId,
        "",
        "2",
      );

      debugPrint("Claimed Offer by ID Response: $response");

      if (response == null || response['data'] == null) {
        throw Exception("Invalid response data");
      }

      if (response['data'] is List) {
        if ((response['data'] as List).isEmpty) {
          throw Exception("No claimed offers found");
        }
        return GetofferclaimedbyofferidData.fromJson(response['data'].first);
      } else {
        return GetofferclaimedbyofferidData.fromJson(response['data']);
      }
    } catch (e) {
      debugPrint("Error fetching claimed offer by ID: $e");
      rethrow;
    }
  }
}