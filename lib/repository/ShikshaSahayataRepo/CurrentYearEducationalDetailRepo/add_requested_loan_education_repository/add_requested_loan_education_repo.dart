import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/ShikshaSahayata/CurrentYearEducationDetail/AddRequestedLoanEducation/AddRequestedLoanEducationModelClass.dart';
import 'package:mpm/utils/urls.dart';

class AddRequestedLoanEducationRepository {
  final api = NetWorkApiService();

  Future<AddRequestedLoanEducationModelClass> addRequestedLoanEducation(
      Map<String, dynamic> body) async {
    try {
      final url =
          Urls.add_shiksha_applicant_requested_loan_education_url;

      debugPrint("🔵 Add Requested Loan Education API URL: $url");
      debugPrint("📤 Request Body: $body");

      final safeBody = _convertAllValuesToStrings(body);

      final response = await api.postApi(
        safeBody,
        url,
        "",
        "1",
      );

      debugPrint("🟢 Response: $response");

      return AddRequestedLoanEducationModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Error Adding Requested Loan Education: $e");
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
