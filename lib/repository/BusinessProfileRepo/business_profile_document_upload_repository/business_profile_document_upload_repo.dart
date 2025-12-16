import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mpm/model/BusinessProfile/BusinessProfileDocument/BusinessProfileDocumentModelClass.dart';
import 'package:mpm/utils/urls.dart';

class BusinessProfileDocumentUploadRepository {
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

  Future<BusinessProfileDocumentModelClass>
  uploadBusinessProfileDocument({
    required String memberBusinessOccupationProfileId,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'member_business_occupation_profile_id':
        memberBusinessOccupationProfileId,
        'business_profile_document':
        await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _dio.post(
        Urls.upload_business_profile_document,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      debugPrint(
          "📎 Business Profile Document Upload Response: ${response.data}");

      return BusinessProfileDocumentModelClass.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("❌ Dio upload error: ${e.response?.data}");
      rethrow;
    } catch (e) {
      debugPrint("❌ Upload error: $e");
      rethrow;
    }
  }
}
