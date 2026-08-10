import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/JobPortal/GetJobById/GetJobByIdModelClass.dart';
import 'package:mpm/utils/urls.dart';

class GetJobByIdRepository {
  final api = NetWorkApiService();

  Future<GetJobByIdModelClass> getJobById(
      String jobId) async {
    try {
      final url =
          "${Urls.get_job_by_id_url}?job_id=$jobId";

      debugPrint("🔵 Get Job By Id URL: $url");

      final response = await api.getApi(
        url,
        "",
      );

      debugPrint("🟢 Response: $response");

      return GetJobByIdModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Error Get Job By Id: $e");
      rethrow;
    }
  }
}