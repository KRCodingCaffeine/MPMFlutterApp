import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/ShikshaSahayata/EducationDetail/DeleteEducationDetail/DeleteEducationDetailModelClass.dart';
import 'package:mpm/utils/urls.dart';

class DeleteEducationRepository {
  final api = NetWorkApiService();

  Future<DeleteEducationDetailModelClass> deleteEducation(
      Map<String, dynamic> body) async {
    try {
      final url =
          Urls.delete_shiksha_applicant_education_url;

      debugPrint("🔵 Delete Education API URL: $url");
      debugPrint("📤 Request Body: $body");

      final safeBody = _convertAllValuesToStrings(body);

      final response = await api.postApi(
        safeBody,
        url,
        "",
        "1", // JSON type
      );

      debugPrint("🟢 Response: $response");

      return DeleteEducationDetailModelClass.fromJson(response);

    } catch (e) {
      debugPrint("❌ Error Deleting Education: $e");
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
