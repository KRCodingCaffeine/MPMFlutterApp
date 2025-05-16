import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mpm/model/GetClaimedOfferByID/GetClaimedOfferByIDModelClass.dart';
import 'package:mpm/model/GetClaimedOfferByID/GetClaimedOfferData.dart';
import 'package:mpm/utils/urls.dart';
import 'package:http/http.dart' as http;

class ClaimOfferRepository {
  Future<ClaimedOfferModel> fetchClaimedOffersByMemberId(int memberId) async {
    try {
      final uri = Uri.parse(Urls.claimed_offer);
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'member_id': memberId.toString(),
        },
      );

      debugPrint("Claimed Offers Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ClaimedOfferModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load claimed offers. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error fetching claimed offers: $e");
      rethrow;
    }
  }


  Future<dynamic> submitClaimedOffer(GetClaimedOfferData claimData) async {
    try {
      final uri = Uri.parse(Urls.claimed_offer);
      var request = http.MultipartRequest('POST', uri);

      // Basic fields
      request.fields['member_claim_offer_id'] = claimData.memberClaimOfferId.toString();
      request.fields['order_no'] = claimData.orderNo ?? '';
      request.fields['member_id'] = claimData.memberId.toString();
      request.fields['org_details_id'] = claimData.orgDetailsId.toString();
      request.fields['organisation_subcategory_id'] = claimData.organisationSubcategoryId.toString();
      request.fields['created_by'] = claimData.createdBy.toString();
      request.fields['created_at'] = claimData.createdAt ?? '';

      // Encode medicines list
      request.fields['medicines'] = jsonEncode(
        claimData.medicines?.map((e) => e.toJson()).toList() ?? [],
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("Submit Claimed Offer Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to submit claimed offer. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error submitting claimed offer: $e");
      rethrow;
    }
  }
}