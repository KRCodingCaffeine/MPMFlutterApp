class GetClaimedOfferData {
  int? memberClaimOfferId;
  String? orderNo;
  int? memberId;
  int? orgDetailsId;
  int? organisationSubcategoryId;
  int? createdBy;
  String? createdAt;
  List<ClaimedMedicine>? medicines;

  GetClaimedOfferData({
    this.memberClaimOfferId,
    this.orderNo,
    this.memberId,
    this.orgDetailsId,
    this.organisationSubcategoryId,
    this.createdBy,
    this.createdAt,
    this.medicines,
  });

  factory GetClaimedOfferData.fromJson(Map<String, dynamic> json) {
    return GetClaimedOfferData(
      memberClaimOfferId: json['member_claim_offer_id'],
      orderNo: json['order_no'],
      memberId: json['member_id'],
      orgDetailsId: json['org_details_id'],
      organisationSubcategoryId: json['organisation_subcategory_id'],
      createdBy: json['created_by'],
      createdAt: json['created_at'],
      medicines: json['medicines'] != null
          ? List<ClaimedMedicine>.from(
          json['medicines'].map((x) => ClaimedMedicine.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'member_claim_offer_id': memberClaimOfferId,
    'order_no': orderNo,
    'member_id': memberId,
    'org_details_id': orgDetailsId,
    'organisation_subcategory_id': organisationSubcategoryId,
    'created_by': createdBy,
    'created_at': createdAt,
    'medicines': medicines?.map((x) => x.toJson()).toList(),
  };
}

class ClaimedMedicine {
  int? memberMedicineOrderId;
  String? medicineName;
  int? medicineContainerId;
  int? quantity;

  ClaimedMedicine({
    this.memberMedicineOrderId,
    this.medicineName,
    this.medicineContainerId,
    this.quantity,
  });

  factory ClaimedMedicine.fromJson(Map<String, dynamic> json) {
    return ClaimedMedicine(
      memberMedicineOrderId: json['member_medicine_order_id'],
      medicineName: json['medicine_name'],
      medicineContainerId: json['medicine_container_id'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() => {
    'member_medicine_order_id': memberMedicineOrderId,
    'medicine_name': medicineName,
    'medicine_container_id': medicineContainerId,
    'quantity': quantity,
  };
}