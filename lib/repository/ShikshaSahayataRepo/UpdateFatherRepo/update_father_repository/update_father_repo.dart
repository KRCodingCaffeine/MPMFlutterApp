import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/ShikshaSahayata/UpdateFatherDetail/UpdateFatherModelClass.dart';
import 'package:mpm/utils/urls.dart';

class UpdateFatherRepository {
  final api = NetWorkApiService();

  Future<UpdateFatherModelClass> updateFatherData(
      Map<String, dynamic> body) async {
    try {
      final url = Urls.update_father_data_url;

      debugPrint("🔵 Update Father API URL: $url");
      debugPrint("📤 Request Body: $body");

      final safeBody = _convertAllValuesToStrings(body);

      final response = await api.postApi(
        safeBody,
        url,
        "",
        "1", // JSON type
      );

      debugPrint("🟢 Response: $response");

      return UpdateFatherModelClass.fromJson(response);

    } catch (e) {
      debugPrint("❌ Error Updating Father Data: $e");
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
