class UpdateVitranMemberOrderProductData {
  String? vitranMemberOrderProductId;

  String? vitranMemberOrderId;

  String? productId;

  String? productUnitId;

  int? productQty;

  double? productCost;

  double? productTotalCost;

  String? createdBy;

  UpdateVitranMemberOrderProductData({
    this.vitranMemberOrderProductId,
    this.vitranMemberOrderId,
    this.productId,
    this.productUnitId,
    this.productQty,
    this.productCost,
    this.productTotalCost,
    this.createdBy,
  });

  factory UpdateVitranMemberOrderProductData.fromJson(
      Map<String, dynamic> json) {
    return UpdateVitranMemberOrderProductData(
      vitranMemberOrderProductId:
      json["vitran_member_order_product_id"]
          ?.toString(),

      vitranMemberOrderId:
      json["vitran_member_order_id"]
          ?.toString(),

      productId:
      json["product_id"]?.toString(),

      productUnitId:
      json["product_unit_id"]?.toString(),

      productQty:
      int.tryParse(json["product_qty"].toString()),

      productCost:
      double.tryParse(json["product_cost"].toString()),

      productTotalCost:
      double.tryParse(
          json["product_total_cost"].toString()),

      createdBy:
      json["created_by"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "vitran_member_order_product_id":
      vitranMemberOrderProductId,

      "vitran_member_order_id":
      vitranMemberOrderId,

      "product_id": productId,

      "product_unit_id": productUnitId,

      "product_qty": productQty,

      "product_cost": productCost,

      "product_total_cost": productTotalCost,

      "created_by": createdBy,
    };
  }
}