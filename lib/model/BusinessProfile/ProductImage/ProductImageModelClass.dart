import 'package:mpm/model/BusinessProfile/ProductImage/ProductImageData.dart';

class ProductImageModelClass {
  final bool status;
  final int code;
  final String message;
  final ProductImageData? data;

  ProductImageModelClass({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory ProductImageModelClass.fromJson(Map<String, dynamic> json) {
    return ProductImageModelClass(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ProductImageData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,
      'data': data?.toJson(),
    };
  }
}
