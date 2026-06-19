import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/QrCodeScanner/FoodQrResponseModel.dart';
import 'package:mpm/model/QrCodeScanner/QrCodeScannerModelClass.dart';
import 'package:mpm/utils/urls.dart';

class QrCodeScannerRepository {
  final api = NetWorkApiService();

  /// Sends attendee code to the API for verification
  Future<QrCodeScannerResponse> scanQrCode(String attendeeCode) async {
    try {
      if (attendeeCode.isEmpty) {
        throw Exception("Attendee code cannot be empty");
      }

      // ✅ Append attendee_code as a query parameter
      final url = "${Urls.scan_qrcode_event}?attendee_code=$attendeeCode";

      final response = await api.getApi(url, "");

      debugPrint("QR Code Scanner Response: $response");

      return QrCodeScannerResponse.fromJson(response);
    } catch (e) {
      debugPrint("Error scanning QR code: $e");
      rethrow;
    }
  }

  /// 🍱 Scan QR for Food Entry
  Future<FoodQrResponse> scanQrCodeForFood(String attendeeCode) async {
    try {
      if (attendeeCode.isEmpty) {
        throw Exception("Attendee code cannot be empty");
      }

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
