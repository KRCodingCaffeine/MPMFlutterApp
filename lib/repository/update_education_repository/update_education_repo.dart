import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/UpdateEducation/UpdateEducationModelClass.dart';
import 'package:mpm/utils/urls.dart';

class UpdateProfileEducationRepository {
  final api = NetWorkApiService();

  Future<UpdateEducationModelClass> updateprofileEducation(
      Map<String, dynamic> body) async {

    try {

      final url = Urls.update_education_url;

      debugPrint("🔵 Update Education API URL: $url");
      debugPrint("📤 Request Body: $body");

      final safeBody = _convertAllValuesToStrings(body);

      final response = await api.postApi(
        safeBody,
        url,
        "",
        "2", // x-www-form-urlencoded
      );

      debugPrint("🟢 Response: $response");

      return UpdateEducationModelClass.fromJson(response);

    } catch (e) {
      debugPrint("❌ Error Updating Education: $e");
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