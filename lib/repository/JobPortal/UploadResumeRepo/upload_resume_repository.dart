import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mpm/model/JobPortal/UploadResume/UploadResumeModelClass.dart';
import 'package:mpm/utils/urls.dart';

class UploadResumeRepository {
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

  Future<UploadResumeModelClass> uploadResume({
    required String memberId,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'member_id': memberId,
        'resume': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _dio.post(
        Urls.upload_seeker_resume_url, // your API URL
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      debugPrint("📄 Resume Upload Response: ${response.data}");

      return UploadResumeModelClass.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("❌ Resume upload dio error: ${e.response?.data}");
      rethrow;
    } catch (e) {
      debugPrint("❌ Resume upload error: $e");
      rethrow;
    }
  }
}