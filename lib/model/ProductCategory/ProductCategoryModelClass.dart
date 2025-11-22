import 'package:mpm/model/ProductCategory/ProductCategoryData.dart';

class ProductCategoryModelClass {
  bool? status;
  int? code;
  String? message;
  int? total;
  List<ProductCategoryData>? data;

 ProductCategoryModelClass({
    this.status,
    this.code,
    this.message,
    this.total,
    this.data,
  });

  ProductCategoryModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    message = json['message'];
    total = json['total'];

    if (json['data'] != null) {
      data = <ProductCategoryData>[];
      json['data'].forEach((v) {
        data!.add(ProductCategoryData.fromJson(v));
      });
    }
  }
}
