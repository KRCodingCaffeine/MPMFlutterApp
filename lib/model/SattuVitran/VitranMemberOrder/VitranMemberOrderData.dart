import 'VitranMemberOrderProductData.dart';

class VitranMemberOrderData {
  String? vitranMemberOrderId;
  String? vitranOrderCode;
  String? vitranId;
  String? memberId;
  String? vitranDistributionCenterId;
  double? totalCost;
  String? orderStatus;
  String? orderedBy;
  String? orderedAt;

  List<VitranMemberOrderProductData>? products;

  VitranMemberOrderData({
    this.vitranMemberOrderId,
    this.vitranOrderCode,
    this.vitranId,
    this.memberId,
    this.vitranDistributionCenterId,
    this.totalCost,
    this.orderStatus,
    this.orderedBy,
    this.orderedAt,
    this.products,
  });

  factory VitranMemberOrderData.fromJson(
      Map<String, dynamic> json) {
    return VitranMemberOrderData(
      vitranMemberOrderId:
      json['vitran_member_order_id']?.toString(),
      vitranOrderCode: json['vitran_order_code']?.toString(),
      vitranId: json['vitran_id']?.toString(),
      memberId: json['member_id']?.toString(),
      vitranDistributionCenterId:
      json['vitran_distribution_center_id']?.toString(),
      totalCost:
      double.tryParse(json['total_cost'].toString()),
      orderStatus: json['order_status'],
      orderedBy: json['ordered_by']?.toString(),
      orderedAt: json['ordered_at'],
      products: json['products'] != null
          ? (json['products'] as List)
          .map((e) =>
          VitranMemberOrderProductData.fromJson(e))
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
      "products": products?.map((e) => e.toJson()).toList(),
    };
  }
}