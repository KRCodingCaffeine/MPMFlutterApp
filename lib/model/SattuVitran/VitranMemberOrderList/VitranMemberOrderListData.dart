import 'package:mpm/model/SattuVitran/VitranMemberOrderList/VitranMemberOrderProductListData.dart';

class VitranMemberOrderListData {
  String? vitranMemberOrderId;
  String? vitranId;
  String? memberId;
  String? vitranDistributionCenterId;

  String? vitranName;
  String? vitranStatus;

  String? vitranDistributionCenterName;
  String? vitranDistributionCenterDetails;
  String? distributionCenterZoneId;
  String? distributionCenterStatus;

  double? totalCost;

  String? orderStatus;
  String? orderedBy;
  String? orderedAt;
  String? updatedBy;
  String? updatedAt;

  List<VitranMemberOrderProductListData>? products;

  VitranMemberOrderListData({
    this.vitranMemberOrderId,
    this.vitranId,
    this.memberId,
    this.vitranDistributionCenterId,
    this.vitranName,
    this.vitranStatus,
    this.vitranDistributionCenterName,
    this.vitranDistributionCenterDetails,
    this.distributionCenterZoneId,
    this.distributionCenterStatus,
    this.totalCost,
    this.orderStatus,
    this.orderedBy,
    this.orderedAt,
    this.updatedBy,
    this.updatedAt,
    this.products,
  });

  factory VitranMemberOrderListData.fromJson(
      Map<String, dynamic> json) {
    return VitranMemberOrderListData(
      vitranMemberOrderId:
      json["vitran_member_order_id"]?.toString(),
      vitranId: json["vitran_id"]?.toString(),
      memberId: json["member_id"]?.toString(),
      vitranDistributionCenterId:
      json["vitran_distribution_center_id"]?.toString(),

      vitranName: json["vitran_name"],
      vitranStatus: json["vitran_status"],

      vitranDistributionCenterName:
      json["vitran_distribution_center_name"],
      vitranDistributionCenterDetails:
      json["vitran_distribution_center_details"],
      distributionCenterZoneId:
      json["distribution_center_zone_id"]?.toString(),
      distributionCenterStatus:
      json["distribution_center_status"]?.toString(),

      totalCost:
      double.tryParse(json["total_cost"].toString()),

      orderStatus: json["order_status"],
      orderedBy: json["ordered_by"]?.toString(),
      orderedAt: json["ordered_at"],
      updatedBy: json["updated_by"]?.toString(),
      updatedAt: json["updated_at"],

      products: json["products"] != null
          ? (json["products"] as List)
          .map((e) =>
          VitranMemberOrderProductListData.fromJson(e))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "vitran_member_order_id": vitranMemberOrderId,
      "vitran_id": vitranId,
      "member_id": memberId,
      "vitran_distribution_center_id":
      vitranDistributionCenterId,
      "vitran_name": vitranName,
      "vitran_status": vitranStatus,
      "vitran_distribution_center_name":
      vitranDistributionCenterName,
      "vitran_distribution_center_details":
      vitranDistributionCenterDetails,
      "distribution_center_zone_id":
      distributionCenterZoneId,
      "distribution_center_status":
      distributionCenterStatus,
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