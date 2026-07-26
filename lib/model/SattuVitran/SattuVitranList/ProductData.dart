import 'package:mpm/utils/urls.dart';

class ProductData {
  String? vitranProductId;
  String? vitranId;
  String? productName;
  String? productDescription;
  String? productUnit;
  String? productImage;
  String? productCost;
  String? createdBy;
  String? createdAt;
  String? updatedBy;
  String? updatedAt;
  String? vitranProductUnitId;
  String? productUnitDisplayName;

  ProductData({
    this.vitranProductId,
    this.vitranId,
    this.productName,
    this.productDescription,
    this.productUnit,
    this.productImage,
    this.productCost,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.vitranProductUnitId,
    this.productUnitDisplayName,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      vitranProductId: json['vitran_product_id']?.toString(),
      vitranId: json['vitran_id']?.toString(),
      productName: json['product_name'],
      productDescription: json['product_description'],
      productUnit: json['product_unit']?.toString(),
      productImage: json['product_image'] != null
          ? Urls.imagePathUrl + json['product_image']
          : null,
      productCost: json['product_cost']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at'],
      updatedBy: json['updated_by']?.toString(),
      updatedAt: json['updated_at'],
      vitranProductUnitId: json['vitran_product_unit_id']?.toString(),
      productUnitDisplayName: json['product_unit_display_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vitran_product_id': vitranProductId,
      'vitran_id': vitranId,
      'product_name': productName,
      'product_description': productDescription,
      'product_unit': productUnit,
      'product_image': productImage,
      'product_cost': productCost,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_by': updatedBy,
      'updated_at': updatedAt,
      'vitran_product_unit_id': vitranProductUnitId,
      'product_unit_display_name': productUnitDisplayName,
    };
  }
}
