import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:mpm/model/JobPortal/UploadJobProfileDocument/UploadJobProfileDocumentModelClass.dart';
import 'package:mpm/utils/urls.dart';

class UploadJobProfileDocumentRepository {
  final Dio _dio = Dio(
    BaseOptions(
      headers: {
        'Accept': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  Future<UploadJobProfileDocumentModelClass>
  uploadJobProfileDocument({
    required String memberId,
    required String jobId,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'member_id': memberId,
        'job_id': jobId,
        'profile_summary_document': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split(RegExp(r'[\\/]')).last,
        ),
      });

      final response = await _dio.post(
        Urls.upload_job_profile_document_url,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      debugPrint(
          "📄 Job Profile Document Upload Response: ${response.data}");

      return UploadJobProfileDocumentModelClass.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint(
          "❌ Job Profile Document Upload Dio Error: ${e.response?.data}");
      rethrow;
    } catch (e) {
      debugPrint(
          "❌ Job Profile Document Upload Error: $e");
      rethrow;
    }
  }
}