class GetClaimedOfferData {
  int? memberClaimOfferId;
  String? orderNo;
  int? memberId;
  int? orgDetailsId;
  int? organisationSubcategoryId;
  String? organisationSubcategoryName; // Added new field
  int? createdBy;
  String? createdAt;
  String? orgName; // Added new field
  String? orgAddress; // Added new field
  String? orgCity; // Added new field
  String? orgState; // Added new field
  String? orgMobile; // Added new field
  String? orgEmail; // Added new field
  String? orgLogo; // Added new field
  List<ClaimedMedicine>? medicines;

  GetClaimedOfferData({
    this.memberClaimOfferId,
    this.orderNo,
    this.memberId,
    this.orgDetailsId,
    this.organisationSubcategoryId,
    this.organisationSubcategoryName,
    this.createdBy,
    this.createdAt,
    this.orgName,
    this.orgAddress,
    this.orgCity,
    this.orgState,
    this.orgMobile,
    this.orgEmail,
    this.orgLogo,
    this.medicines,
  });

  factory GetClaimedOfferData.fromJson(Map<String, dynamic> json) {
    return GetClaimedOfferData(
      memberClaimOfferId: _toInt(json['member_claim_offer_id']),
      orderNo: json['order_no'] as String?,
      memberId: _toInt(json['member_id']),
      orgDetailsId: _toInt(json['org_details_id']),
      organisationSubcategoryId: _toInt(json['organisation_subcategory_id']),
      organisationSubcategoryName: json['organisation_subcategory_name'] as String?,
      createdBy: _toInt(json['created_by']),
      createdAt: json['created_at'] as String?,
      orgName: json['org_name'] as String?,
      orgAddress: json['org_address'] as String?,
      orgCity: json['org_city'] as String?,
      orgState: json['org_state'] as String?,
      orgMobile: json['org_mobile'] as String?,
      orgEmail: json['org_email'] as String?,
      orgLogo: "https://members.mumbaimaheshwari.com/api/public/" +json['org_logo'],
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
    'organisation_subcategory_name': organisationSubcategoryName,
    'created_by': createdBy,
    'created_at': createdAt,
    'org_name': orgName,
    'org_address': orgAddress,
    'org_city': orgCity,
    'org_state': orgState,
    'org_mobile': orgMobile,
    'org_email': orgEmail,
    'org_logo': orgLogo,
    'medicines': medicines?.map((x) => x.toJson()).toList(),
  };

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
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
      memberMedicineOrderId: _toInt(json['member_medicine_order_id']),
      medicineName: json['medicine_name'] as String?,
      medicineContainerId: _toInt(json['medicine_container_id']),
      quantity: _toInt(json['quantity']),
    );
  }

  Map<String, dynamic> toJson() => {
    'member_medicine_order_id': memberMedicineOrderId,
    'medicine_name': medicineName,
    'medicine_container_id': medicineContainerId,
    'quantity': quantity,
  };

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}