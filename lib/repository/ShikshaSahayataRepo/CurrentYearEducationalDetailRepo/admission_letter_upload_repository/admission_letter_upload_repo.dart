import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mpm/model/ShikshaSahayata/CurrentYearEducationDetail/AdmissionConfirmationletterUpload/AdmissionUploadModelClass.dart';
import 'package:mpm/utils/urls.dart';

class AdmissionUploadRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Urls.base_url,
      headers: {'Accept': 'application/json'},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  Future<AdmissionUploadModelClass> uploadAdmissionLetter({
    required String shikshaApplicantId,
    required String educationId,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'shiksha_applicant_id': shikshaApplicantId,
        'shiksha_applicant_requested_loan_education_id': educationId,
        'admission_confirmation_letter_doc':
        await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _dio.post(
        Urls.upload_admission_letter_url,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      debugPrint("📄 Admission Upload Response: ${response.data}");

      return AdmissionUploadModelClass.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("❌ Admission upload error: ${e.response?.data}");
      rethrow;
    }
  }
}
