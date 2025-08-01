import 'package:mpm/utils/urls.dart';

class GetClaimedOfferData {
  int? memberClaimOfferId;
  String? orderNo;
  String? medicinePrescriptionDocument;
  String? memberClaimDocument;
  int? memberId;
  int? orgDetailsId;
  int? organisationSubcategoryId;
  String? organisationSubcategoryName;
  int? createdBy;
  String? createdAt;
  String? orgName;
  String? orgAddress;
  String? orgCity;
  String? orgState;
  String? orgMobile;
  String? orgEmail;
  String? orgLogo;
  String? orgArea;
  String? orgPincode;
  int? organisationOfferDiscountId;
  String? offerDiscountName;
  String? offerDescription;
  String? validFrom;
  String? validTo;
  String? offerImage;
  String? offerContactPersonName;
  String? offerContactPersonMobile;
  List<ClaimedMedicine>? medicines;

  GetClaimedOfferData({
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
    this.orgArea,
    this.orgPincode,
    this.organisationOfferDiscountId,
    this.offerDiscountName,
    this.offerDescription,
    this.validFrom,
    this.validTo,
    this.offerImage,
    this.offerContactPersonName,
    this.offerContactPersonMobile,
    this.medicines,
  });

  factory GetClaimedOfferData.fromJson(Map<String, dynamic> json) {
    return GetClaimedOfferData(
      memberClaimOfferId: _toInt(json['member_claim_offer_id']),
      orderNo: json['order_no'],
      medicinePrescriptionDocument:
          json['medicine_prescription_document']?.isNotEmpty == true
              ? Urls.imagePathUrl + json['medicine_prescription_document']
              : null,
      memberClaimDocument: json['member_claim_document']?.isNotEmpty == true
          ? Urls.imagePathUrl + json['member_claim_document']
          : null,
      memberId: _toInt(json['member_id']),
      orgDetailsId: _toInt(json['org_details_id']),
      organisationSubcategoryId: _toInt(json['organisation_subcategory_id']),
      organisationSubcategoryName: json['organisation_subcategory_name'],
      createdBy: _toInt(json['created_by']),
      createdAt: json['created_at'],
      orgName: json['org_name'],
      orgAddress: json['org_address'],
      orgCity: json['org_city'],
      orgState: json['org_state'],
      orgMobile: json['org_mobile'],
      orgEmail: json['org_email'],
      orgLogo: json['org_logo']?.isNotEmpty == true
          ? Urls.imagePathUrl + json['org_logo']
          : null,
      orgArea: json['org_area'],
      orgPincode: json['org_pincode'],
      organisationOfferDiscountId:
          _toInt(json['organisation_offer_discount_id']),
      offerDiscountName: json['offer_discount_name'],
      offerDescription: json['offer_description'],
      validFrom: json['valid_from'],
      validTo: json['valid_to'],
      offerImage: json['offer_image']?.isNotEmpty == true
          ? Urls.imagePathUrl + json['offer_image']
          : null,
      offerContactPersonName: json['org_contact_person_name'],
      offerContactPersonMobile: json['org_contact_person_mobile'],
      medicines: json['medicines'] != null
          ? List<ClaimedMedicine>.from(
              json['medicines'].map((x) => ClaimedMedicine.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'member_claim_offer_id': memberClaimOfferId,
        'order_no': orderNo,
        'medicine_prescription_document': medicinePrescriptionDocument,
        'member_claim_document': memberClaimDocument,
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
        'org_area': orgArea,
        'org_pincode': orgPincode,
        'organisation_offer_discount_id': organisationOfferDiscountId,
        'offer_discount_name': offerDiscountName,
        'offer_description': offerDescription,
        'valid_from': validFrom,
        'valid_to': validTo,
        'offer_image': offerImage,
        'org_contact_person_name': offerContactPersonName,
        'org_contact_person_mobile': offerContactPersonMobile,
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
      medicineName: json['medicine_name'],
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
