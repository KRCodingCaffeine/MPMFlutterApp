import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/GetOfferImage/OfferImageData.dart';
import 'package:mpm/utils/urls.dart';

class PartnerLogoRepository {
  final api = NetWorkApiService();

  Future<OfferImageResponse> updateOfferImage(Map<String, dynamic> offerImageData) async {
    try {
      final response = await api.postApi(
        offerImageData,
        Urls.offer_image,
        "",
        "2",
      );
      debugPrint("Offer Image Update Response: $response");
      return OfferImageResponse.fromJson(response);
    } catch (e) {
      debugPrint("Error updating offer image: $e");
      rethrow;
    }
  }
}