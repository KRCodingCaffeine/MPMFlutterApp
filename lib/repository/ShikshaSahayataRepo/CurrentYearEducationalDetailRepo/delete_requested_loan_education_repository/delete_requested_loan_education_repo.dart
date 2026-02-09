import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/ShikshaSahayata/CurrentYearEducationDetail/DeleteRequestedLoanEducation/DeleteRequestedLoanEducationModelClass.dart';
import 'package:mpm/utils/urls.dart';

class DeleteRequestedLoanEducationRepository {
  final api = NetWorkApiService();

  Future<DeleteRequestedLoanEducationModelClass>
  deleteRequestedLoanEducation(
      Map<String, dynamic> body) async {
    try {
      final url =
          Urls.delete_shiksha_applicant_requested_loan_education_url;

      debugPrint("🔵 Delete Requested Loan Education API URL: $url");
      debugPrint("📤 Request Body: $body");

      final safeBody = _convertAllValuesToStrings(body);

      final response = await api.postApi(
        safeBody,
        url,
        "",
        "1",
      );

      debugPrint("🟢 Response: $response");

      return DeleteRequestedLoanEducationModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Error Deleting Requested Loan Education: $e");
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
