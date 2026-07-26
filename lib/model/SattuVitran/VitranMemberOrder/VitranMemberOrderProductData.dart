class VitranMemberOrderProductData {
  String? vitranMemberOrderProductId;
  String? productId;
  String? productUnitId;
  int? productQty;
  double? productCost;
  double? productTotalCost;
  String? vitranMemberOrderId;
  String? createdBy;

  VitranMemberOrderProductData({
    this.vitranMemberOrderProductId,
    this.productId,
    this.productUnitId,
    this.productQty,
    this.productCost,
    this.productTotalCost,
    this.vitranMemberOrderId,
    this.createdBy,
  });

  factory VitranMemberOrderProductData.fromJson(Map<String, dynamic> json) {
    return VitranMemberOrderProductData(
      vitranMemberOrderProductId:
          json['vitran_member_order_product_id']?.toString(),
      productId: json['product_id']?.toString(),
      productUnitId: json['product_unit_id']?.toString(),
      productQty: int.tryParse(json['product_qty'].toString()),
      productCost: double.tryParse(json['product_cost'].toString()),
      productTotalCost: double.tryParse(json['product_total_cost'].toString()),
      vitranMemberOrderId: json['vitran_member_order_id']?.toString(),
      createdBy: json['created_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "vitran_member_order_product_id": vitranMemberOrderProductId,
      "product_id": productId,
      "product_unit_id": productUnitId,
      "product_qty": productQty,
      "product_cost": productCost,
      "product_total_cost": productTotalCost,
      "vitran_member_order_id": vitranMemberOrderId,
      "created_by": createdBy,
    };
  }
}
