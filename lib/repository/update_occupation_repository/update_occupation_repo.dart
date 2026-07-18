import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/utils/urls.dart';

class UpdateOccupationRepository {
  final api = NetWorkApiService();

  Future<bool> updateOccupation(Map<String, dynamic> body) async {
    try {
      final url = Urls.update_occupation_url;

      debugPrint("UPLOAD OCCUPATION API URL: $url");
      debugPrint("UPLOAD OCCUPATION RAW BODY: $body");

      final safeBody = _convertAllValuesToStrings(body);
      debugPrint("UPLOAD OCCUPATION FORM BODY: $safeBody");

      final response = await api.postApi(safeBody, url, "", "2");

      debugPrint("UPLOAD OCCUPATION API RESPONSE: $response");

      if (response != null &&
          (response["status"] == true || response["status"] == "true") &&
          (response["code"] == null ||
              response["code"] == 200 ||
              response["code"] == "200")) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint("UPLOAD OCCUPATION API ERROR: $e");
      return false;
    }
  }

  Map<String, dynamic> _convertAllValuesToStrings(Map<String, dynamic> body) {
    final safeBody = <String, dynamic>{};

    body.forEach((key, value) {
      safeBody[key] = value?.toString() ?? '';
    });

    return safeBody;
  }
}
