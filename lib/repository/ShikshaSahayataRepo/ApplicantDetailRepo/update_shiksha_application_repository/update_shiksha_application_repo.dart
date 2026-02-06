import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/ShikshaSahayata/ApplicantDetail/CreateApplicantDetail/CreateApplicantDetailModalClass.dart';
import 'package:mpm/model/ShikshaSahayata/ApplicantDetail/UpdateApplicantDetail/UpdateApplicantDetailModelClass.dart';
import 'package:mpm/utils/urls.dart';

class UpdateShikshaApplicationRepository {
final api = NetWorkApiService();

Future<UpdateApplicantDetailModelClass> updateShikshaApplication(
    Map<String, dynamic> body) async {
  try {
    final url = Urls.update_shiksha_application_url;

    final response = await api.postApi(
      body,
      url,
      "",
      "1",
    );

    return UpdateApplicantDetailModelClass.fromJson(response);
  } catch (e) {
    debugPrint("❌ Error Updating Shiksha Application: $e");
    rethrow;
  }
}
}
