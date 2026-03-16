import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/UpdateMoreOccupation/UpdateMoreOccupationModelClass.dart';
import 'package:mpm/utils/urls.dart';

class UpdateMoreOccupationRepository {

  final api = NetWorkApiService();

  Future<UpdateMoreOccupationModelClass> updateMoreOccupation(
      Map<String, dynamic> body) async {

    try {

      final url = Urls.update_more_occupation_url;

      debugPrint("🔵 Update Occupation API URL: $url");
      debugPrint("📤 Request Body: $body");

      final safeBody = _convertAllValuesToStrings(body);

      final response = await api.postApi(
        safeBody,
        url,
        "",
        "2", // x-www-form-urlencoded
      );

      debugPrint("🟢 Response: $response");

      return UpdateMoreOccupationModelClass.fromJson(response);

    } catch (e) {

      debugPrint("❌ Error Updating Occupation: $e");
      rethrow;

    }
  }

  Map<String, dynamic> _convertAllValuesToStrings(
      Map<String, dynamic> body) {

    final safeBody = <String, dynamic>{};

    body.forEach((key, value) {
      safeBody[key] = value?.toString() ?? '';
    });

    return safeBody;
  }
}