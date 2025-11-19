import 'package:mpm/model/ProductSubcategory/ProductSubcategoryData.dart';

class ProductSubcategoryModelClass {
  bool? status;
  int? code;
  String? message;
  int? total;
  List<ProductSubcategoryData>? data;

  ProductSubcategoryModelClass({
    this.status,
    this.code,
    this.message,
    this.total,
    this.data,
  });

  ProductSubcategoryModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    message = json['message'];
    total = json['total'];

    if (json['data'] != null) {
      data = <ProductSubcategoryData>[];
      json['data'].forEach((v) {
        data!.add(ProductSubcategoryData.fromJson(v));
      });
    }
  }
}
