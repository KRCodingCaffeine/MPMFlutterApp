class GetofferclaimedbyofferidData {
  String? memberClaimOfferId;
  String? orderNo;
  String? medicinePrescriptionDocument;
  String? memberClaimDocument;
  String? memberId;
  String? orgDetailsId;
  String? organisationSubcategoryId;
  String? organisationSubcategoryName;
  String? createdBy;
  String? createdAt;
  String? orgName;
  String? orgAddress;
  String? orgCity;
  String? orgState;
  String? orgMobile;
  String? orgEmail;
  String? orgLogo;
  String? organisationOfferDiscountId;
  String? offerDiscountName;
  String? offerDescription;
  String? validFrom;
  String? validTo;
  String? offerImage;
  List<MedicineOrder>? medicines;

  GetofferclaimedbyofferidData({
    this.memberClaimOfferId,
    this.orderNo,
    this.medicinePrescriptionDocument,
    this.memberClaimDocument,
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
    this.organisationOfferDiscountId,
    this.offerDiscountName,
    this.offerDescription,
    this.validFrom,
    this.validTo,
    this.offerImage,
    this.medicines,
  });

  factory GetofferclaimedbyofferidData.fromJson(Map<String, dynamic> json) {
    return GetofferclaimedbyofferidData(
      memberClaimOfferId: json['member_claim_offer_id']?.toString(),
      orderNo: json['order_no'],
      medicinePrescriptionDocument: json['medicine_prescription_document']
          ?.isNotEmpty ==
          true
          ? "https://members.mumbaimaheshwari.com/api/public/${json['medicine_prescription_document']}"
          : null,
      memberClaimDocument: json['member_claim_document']?.isNotEmpty == true
          ? "https://members.mumbaimaheshwari.com/api/public/${json['member_claim_document']}"
          : null,
      memberId: json['member_id']?.toString(),
      orgDetailsId: json['org_details_id']?.toString(),
      organisationSubcategoryId: json['organisation_subcategory_id']?.toString(),
      organisationSubcategoryName: json['organisation_subcategory_name'],
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at'],
      orgName: json['org_name'],
      orgAddress: json['org_address'],
      orgCity: json['org_city'],
      orgState: json['org_state'],
      orgMobile: json['org_mobile'],
      orgEmail: json['org_email'],
      orgLogo: json['org_logo'] != null
          ? "https://members.mumbaimaheshwari.com/api/public/${json['org_logo']}"
          : null,
      organisationOfferDiscountId: json['organisation_offer_discount_id']?.toString(),
      offerDiscountName: json['offer_discount_name'],
      offerDescription: json['offer_description'],
      validFrom: json['valid_from'],
      validTo: json['valid_to'],
      offerImage: json['offer_image'] != null
          ? "https://members.mumbaimaheshwari.com/api/public/${json['offer_image']}"
          : null,
      medicines: json['medicines'] != null
          ? List<MedicineOrder>.from(
          json['medicines'].map((x) => MedicineOrder.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['member_claim_offer_id'] = memberClaimOfferId;
    data['order_no'] = orderNo;
    data['medicine_prescription_document'] = medicinePrescriptionDocument;
    data['member_claim_document'] = memberClaimDocument;
    data['member_id'] = memberId;
    data['org_details_id'] = orgDetailsId;
    data['organisation_subcategory_id'] = organisationSubcategoryId;
    data['organisation_subcategory_name'] = organisationSubcategoryName;
    data['created_by'] = createdBy;
    data['created_at'] = createdAt;
    data['org_name'] = orgName;
    data['org_address'] = orgAddress;
    data['org_city'] = orgCity;
    data['org_state'] = orgState;
    data['org_mobile'] = orgMobile;
    data['org_email'] = orgEmail;
    data['org_logo'] = orgLogo;
    data['organisation_offer_discount_id'] = organisationOfferDiscountId;
    data['offer_discount_name'] = offerDiscountName;
    data['offer_description'] = offerDescription;
    data['valid_from'] = validFrom;
    data['valid_to'] = validTo;
    data['offer_image'] = offerImage;
    if (medicines != null) {
      data['medicines'] = medicines!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MedicineOrder {
  String? memberMedicineOrderId;
  String? medicineName;
  String? medicineContainerId;
  String? quantity;

  MedicineOrder({
    this.memberMedicineOrderId,
    this.medicineName,
    this.medicineContainerId,
    this.quantity,
  });

  factory MedicineOrder.fromJson(Map<String, dynamic> json) {
    return MedicineOrder(
      memberMedicineOrderId: json['member_medicine_order_id']?.toString(),
      medicineName: json['medicine_name'],
      medicineContainerId: json['medicine_container_id']?.toString(),
      quantity: json['quantity']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['member_medicine_order_id'] = memberMedicineOrderId;
    data['medicine_name'] = medicineName;
    data['medicine_container_id'] = medicineContainerId;
    data['quantity'] = quantity;
    return data;
  }
}