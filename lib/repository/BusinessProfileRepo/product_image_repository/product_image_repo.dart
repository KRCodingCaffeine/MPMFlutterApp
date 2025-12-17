import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mpm/model/BusinessProfile/ProductImage/ProductImageModelClass.dart';
import 'package:mpm/utils/urls.dart';

class ProductImageUploadRepository {
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

  Future<ProductImageModelClass> uploadProductImage({
    required String productServiceId,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'product_service_id': productServiceId,
        'product_image': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _dio.post(
        Urls.upload_product_image, // ✅ correct product image API
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      debugPrint(
          "🖼 Product Image Upload Response: ${response.data}");

      return ProductImageModelClass.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("❌ Dio product image upload error: ${e.response?.data}");
      rethrow;
    } catch (e) {
      debugPrint("❌ Product image upload error: $e");
      rethrow;
    }
  }
}
