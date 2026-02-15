import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/ShikshaSahayata/ApplicantDetail/CreateApplicantDetail/CreateApplicantDetailModalClass.dart';
import 'package:mpm/utils/urls.dart';

class CreateShikshaApplicationRepository {
  final api = NetWorkApiService();

  Future<CreateApplicantDetailModelClass> createShikshaApplication(
      Map<String, dynamic> body) async {
    try {
      final url = Urls.create_shiksha_application_url;

      debugPrint("🔵 Create Shiksha Application API URL: $url");
      debugPrint("📤 Request Body: $body");

      final safeBody = _convertAllValuesToStrings(body);

      final response = await api.postApi(
        safeBody,
        url,
        "",
        "1", // JSON type
      );

      debugPrint("🟢 Response: $response");

      return CreateApplicantDetailModelClass.fromJson(response);

    } catch (e) {
      debugPrint("❌ Error Creating Shiksha Application: $e");
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
