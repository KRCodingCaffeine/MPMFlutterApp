import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/QrCodeScanner/FoodQrResponseModel.dart';
import 'package:mpm/utils/urls.dart';


class QrCodeScannerRepository {
  final api = NetWorkApiService();

  /// 🍱 Scan QR for Food Entry
  Future<FoodQrResponse> scanQrCodeForFood(String attendeeCode) async {
    try {
      if (attendeeCode.isEmpty) {
        throw Exception("Attendee code cannot be empty");
      }

      /// ✅ API URL
      final url =
          "${Urls.scan_qrcode_for_food}?attendee_code=$attendeeCode";

      debugPrint("FOOD API URL: $url");

      final response = await api.getApi(url, "");

      debugPrint("FOOD API RESPONSE: $response");

      return FoodQrResponse.fromJson(response);
    } catch (e) {
      debugPrint("Error scanning food QR code: $e");
      rethrow;
    }
  }
}