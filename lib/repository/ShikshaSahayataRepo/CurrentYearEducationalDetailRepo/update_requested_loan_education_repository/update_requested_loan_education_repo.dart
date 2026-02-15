import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/ShikshaSahayata/CurrentYearEducationDetail/UpdateRequestedLoanEducation/UpdateRequestedLoanEducationModelClass.dart';
import 'package:mpm/utils/urls.dart';

class UpdateRequestedLoanEducationRepository {
  final api = NetWorkApiService();

  Future<UpdateRequestedLoanEducationModelClass>
  updateRequestedLoanEducation(
      Map<String, dynamic> body) async {
    try {
      final url =
          Urls.update_shiksha_applicant_requested_loan_education_url;

      debugPrint("🔵 Update Requested Loan Education API URL: $url");
      debugPrint("📤 Request Body: $body");

      final safeBody = _convertAllValuesToStrings(body);

      final response = await api.postApi(
        safeBody,
        url,
        "",
        "1",
      );

      debugPrint("🟢 Response: $response");

      return UpdateRequestedLoanEducationModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Error Updating Requested Loan Education: $e");
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
