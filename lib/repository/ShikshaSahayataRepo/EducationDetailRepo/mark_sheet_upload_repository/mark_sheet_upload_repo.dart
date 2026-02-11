import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mpm/model/ShikshaSahayata/EducationDetail/MarkSheetUpload/MarkSheetUploadModelClass.dart';
import 'package:mpm/utils/urls.dart';

class MarkSheetUploadRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Urls.base_url,
      headers: {
        'Accept': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  Future<MarkSheetUploadModelClass> uploadMarkSheet({
    required String shikshaApplicantId,
    required String educationId,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'shiksha_applicant_id': shikshaApplicantId,
        'shiksha_applicant_education_id': educationId,
        'mark_sheet_attachment': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _dio.post(
        Urls.upload_mark_sheet_attachment_url,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      debugPrint("📄 Marksheet Upload Response: ${response.data}");

      return MarkSheetUploadModelClass.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("❌ Dio Marksheet upload error: ${e.response?.data}");
      rethrow;
    } catch (e) {
      debugPrint("❌ Marksheet upload error: $e");
      rethrow;
    }
  }
}
