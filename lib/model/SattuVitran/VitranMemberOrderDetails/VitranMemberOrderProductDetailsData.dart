class VitranMemberOrderProductDetailsData {
  String? vitranMemberOrderProductId;
  String? vitranMemberOrderId;
  String? productId;
  String? productName;
  String? productDescription;
  String? productUnitId;
  String? productUnitDisplayName;
  int? productQty;
  double? productCost;
  double? productTotalCost;

  VitranMemberOrderProductDetailsData({
    this.vitranMemberOrderProductId,
    this.vitranMemberOrderId,
    this.productId,
    this.productName,
    this.productDescription,
    this.productUnitId,
    this.productUnitDisplayName,
    this.productQty,
    this.productCost,
    this.productTotalCost,
  });

  factory VitranMemberOrderProductDetailsData.fromJson(
      Map<String, dynamic> json) {
    return VitranMemberOrderProductDetailsData(
      vitranMemberOrderProductId:
      json["vitran_member_order_product_id"]?.toString(),

      vitranMemberOrderId:
      json["vitran_member_order_id"]?.toString(),

      productId: json["product_id"]?.toString(),
      productName: json["product_name"],
      productDescription: json["product_description"],

      productUnitId: json["product_unit_id"]?.toString(),

      productUnitDisplayName:
      json["product_unit_display_name"],

      productQty:
      int.tryParse(json["product_qty"].toString()),

      productCost:
      double.tryParse(json["product_cost"].toString()),

      productTotalCost:
      double.tryParse(json["product_total_cost"].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "vitran_member_order_product_id":
      vitranMemberOrderProductId,
      "vitran_member_order_id":
      vitranMemberOrderId,
      "product_id": productId,
      "product_name": productName,
      "product_description": productDescription,
      "product_unit_id": productUnitId,
      "product_unit_display_name":
      productUnitDisplayName,
      "product_qty": productQty,
      "product_cost": productCost,
      "product_total_cost": productTotalCost,
    };
  }
}