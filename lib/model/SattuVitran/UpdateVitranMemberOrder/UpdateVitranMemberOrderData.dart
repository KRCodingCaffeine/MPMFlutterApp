import 'UpdateVitranMemberOrderProductData.dart';

class UpdateVitranMemberOrderData {
  String? vitranMemberOrderId;
  String? vitranOrderCode;
  String? vitranId;
  String? memberId;
  String? vitranDistributionCenterId;

  double? totalCost;

  String? orderStatus;
  String? orderedBy;
  String? orderedAt;
  String? updatedBy;
  String? updatedAt;

  List<UpdateVitranMemberOrderProductData>? products;

  UpdateVitranMemberOrderData({
    this.vitranMemberOrderId,
    this.vitranOrderCode,
    this.vitranId,
    this.memberId,
    this.vitranDistributionCenterId,
    this.totalCost,
    this.orderStatus,
    this.orderedBy,
    this.orderedAt,
    this.updatedBy,
    this.updatedAt,
    this.products,
  });

  factory UpdateVitranMemberOrderData.fromJson(
      Map<String, dynamic> json) {
    return UpdateVitranMemberOrderData(
      vitranMemberOrderId:
      json["vitran_member_order_id"]?.toString(),

      vitranOrderCode:
      json["vitran_order_code"]?.toString(),

      vitranId:
      json["vitran_id"]?.toString(),

      memberId:
      json["member_id"]?.toString(),

      vitranDistributionCenterId:
      json["vitran_distribution_center_id"]?.toString(),

      totalCost:
      double.tryParse(json["total_cost"].toString()),

      orderStatus:
      json["order_status"],

      orderedBy:
      json["ordered_by"]?.toString(),

      orderedAt:
      json["ordered_at"],

      updatedBy:
      json["updated_by"]?.toString(),

      updatedAt:
      json["updated_at"],

      products: json["products"] != null
          ? (json["products"] as List)
          .map((e) =>
          UpdateVitranMemberOrderProductData.fromJson(e))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "vitran_member_order_id": vitranMemberOrderId,
      "vitran_order_code": vitranOrderCode,
      "vitran_id": vitranId,
      "member_id": memberId,
      "vitran_distribution_center_id":
      vitranDistributionCenterId,
      "total_cost": totalCost,
      "order_status": orderStatus,
      "ordered_by": orderedBy,
      "ordered_at": orderedAt,
      "updated_by": updatedBy,
      "updated_at": updatedAt,
      "products":
      products?.map((e) => e.toJson()).toList(),
    };
  }
}