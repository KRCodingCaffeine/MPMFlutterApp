import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/BusinessProfile/ProductImage/ProductImageModelClass.dart';
import 'package:mpm/utils/urls.dart';

class ProductImageUploadRepository {
  final api = NetWorkApiService();

  Future<ProductImageModelClass> uploadProductImage({
    required String productServiceId,
    required String filePath,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'product_service_id': productServiceId,
        'product_image': await MultipartFile.fromFile(filePath),
      });

      final response = await api.postApi(
        formData,
        Urls.upload_product_image,
        "",
        "2",
      );

      debugPrint("Product Image Upload Response: $response");
      return ProductImageModelClass.fromJson(response);

    } catch (e) {
      debugPrint("Error uploading product image: $e");
      rethrow;
    }
  }
}
