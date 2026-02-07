import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/ShikshaSahayata/EducationDetail/AddEducationDetail/AddEducationDetailModelClass.dart';
import 'package:mpm/utils/urls.dart';

class AddEducationRepository {
  final api = NetWorkApiService();

  Future<AddEducationDetailModelClass> addEducation(
      Map<String, dynamic> body) async {
    try {
      final url = Urls.add_shiksha_applicant_education_url;

      debugPrint("🔵 Add Education API URL: $url");
      debugPrint("📤 Request Body: $body");

      final safeBody = _convertAllValuesToStrings(body);

      final response = await api.postApi(
        safeBody,
        url,
        "",
        "1", // JSON type
      );

      debugPrint("🟢 Response: $response");

      return AddEducationDetailModelClass.fromJson(response);

    } catch (e) {
      debugPrint("❌ Error Adding Education: $e");
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
