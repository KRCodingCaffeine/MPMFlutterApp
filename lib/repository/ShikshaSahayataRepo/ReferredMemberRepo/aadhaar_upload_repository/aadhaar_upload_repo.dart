import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mpm/model/ShikshaSahayata/ReferredMember/AadhaarUpload/AadhaarUploadModelClass.dart';
import 'package:mpm/utils/urls.dart';

class AadhaarUploadRepository {
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

  Future<AadhaarUploadModelClass> uploadAadhaar({
    required String shikshaApplicantId,
    required String referenceId,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'shiksha_applicant_id': shikshaApplicantId,
        'shiksha_applicant_referred_member_id': referenceId,
        'refered_member_member_aadhar_card_document': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _dio.post(
        Urls.upload_reference_aadhaar_url,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      debugPrint("🆔 Aadhaar Upload Response: ${response.data}");

      return AadhaarUploadModelClass.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("❌ Dio Aadhaar upload error: ${e.response?.data}");
      rethrow;
    } catch (e) {
      debugPrint("❌ Aadhaar upload error: $e");
      rethrow;
    }
  }
}
