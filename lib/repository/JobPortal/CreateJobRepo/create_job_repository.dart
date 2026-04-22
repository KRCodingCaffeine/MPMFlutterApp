import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/JobPortal/CreateJob/CreateJobModelClass.dart';
import 'package:mpm/utils/urls.dart';

class CreateJobRepository {
  final api = NetWorkApiService();

  Future<CreateJobModelClass> createJob(
      Map<String, dynamic> body) async {
    try {
      final url = Urls.add_job_url;

      debugPrint("🔵 Add Job API URL: $url");
      debugPrint("📤 Request Body: $body");

      final safeBody = _convertAllValuesToStrings(body);

      final response = await api.postApi(
        safeBody,
        url,
        "",
        "2", // x-www-form-urlencoded
      );

      debugPrint("🟢 Response: $response");

      return CreateJobModelClass.fromJson(response);

    } catch (e) {
      debugPrint("❌ Error Creating Job: $e");
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