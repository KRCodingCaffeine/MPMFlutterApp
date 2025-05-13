import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/OfferDiscountById/OfferDiscountByIdData.dart';
import 'package:mpm/model/OfferDiscountById/OfferDiscountByIdModelClass.dart';
import 'package:mpm/utils/urls.dart';

class OfferDiscountByIdRepository {
  final api = NetWorkApiService();

  /// ✅ Fetch all discount offers via GET
  Future<Offerdiscountbyidmodelclass> fetchAllDiscountOffers() async {
    try {
      final response = await api.getApi(
        Urls.offerdiscount_url, // Example: "offer/discount/list"
        "",
      );
      debugPrint("All Discount Offers Response: $response");
      return Offerdiscountbyidmodelclass.fromJson(response);
    } catch (e) {
      debugPrint("Error fetching all discount offers: $e");
      rethrow;
    }
  }

  Future<OfferDiscountByIdData> fetchDiscountOfferById(String id) async {
    try {
      final requestBody = {
        "organisation_offer_discount_id": id // Changed from "offer_id" to match API expectation
      };

      final response = await api.postApi(
        requestBody,
        Urls.discount_offer_url,
        "",
        "2", // Assuming this is your version parameter
      );

      debugPrint("Discount Offer Detail Response: $response");

      // Handle the response based on your API structure
      if (response['status'] == true) {
        return OfferDiscountByIdData.fromJson(response['data'] ?? response);
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch offer details');
      }
    } catch (e) {
      debugPrint("Error fetching discount offer by ID: $e");
      rethrow;
    }
  }
}
