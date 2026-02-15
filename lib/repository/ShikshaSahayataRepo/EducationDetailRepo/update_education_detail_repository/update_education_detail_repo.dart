import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/ShikshaSahayata/EducationDetail/UpdateEducationDetail/UpdateEducationDetailModelClass.dart';
import 'package:mpm/utils/urls.dart';

class UpdateEducationRepository {
  final api = NetWorkApiService();

  Future<UpdateEducationDetailModelClass> updateEducation(
      Map<String, dynamic> body) async {
    try {
      final url =
          Urls.update_shiksha_applicant_education_url;

      debugPrint("🔵 Update Education API URL: $url");
      debugPrint("📤 Request Body: $body");

      final safeBody = _convertAllValuesToStrings(body);

      final response = await api.postApi(
        safeBody,
        url,
        "",
        "1", // JSON type
      );

      debugPrint("🟢 Response: $response");

      return UpdateEducationDetailModelClass.fromJson(response);

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
