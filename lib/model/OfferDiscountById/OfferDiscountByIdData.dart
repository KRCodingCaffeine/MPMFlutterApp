class OfferDiscountByIdData {
  int? organisationOfferDiscountId;
  String? offerDiscountName;
  String? offerDescription;
  String? offerContactPersonName;
  String? offerContactPersonMobile;
  String? validFrom;
  String? validTo;
  String? offerImage;
  String? orgDetailsID;
  String? orgName;
  int? orgCategoryId;
  int? orgSubcategoryId;
  String? orgAddress;
  String? orgArea;
  String? orgCity;
  String? orgState;
  String? orgPincode;
  String? orgMobile;
  String? orgWhatsApp;
  String? orgEmail;
  String? orgLogo;


  OfferDiscountByIdData({
    this.organisationOfferDiscountId,
    this.offerDiscountName,
    this.offerDescription,
    this.offerContactPersonName,
    this.offerContactPersonMobile,
    this.validFrom,
    this.validTo,
    this.offerImage,
    this.orgDetailsID,
    this.orgName,
    this.orgCategoryId,
    this.orgSubcategoryId,
    this.orgAddress,
    this.orgArea,
    this.orgCity,
    this.orgState,
    this.orgPincode,
    this.orgMobile,
    this.orgWhatsApp,
    this.orgEmail,
    this.orgLogo,

  });

  factory OfferDiscountByIdData.fromJson(Map<String, dynamic> json) {
    return OfferDiscountByIdData(
      organisationOfferDiscountId: json['organisation_offer_discount_id'],
      offerDiscountName: json['offer_discount_name'],
      offerDescription: json['offer_description'],
      offerContactPersonName: json['org_contact_person_name'],
      offerContactPersonMobile: json['org_contact_person_mobile'],
      validFrom: json['valid_from'],
      validTo: json['valid_to'],
      offerImage: "https://members.mumbaimaheshwari.com/api/public/" + json['offer_image'],
      orgDetailsID: json['org_details_id'],
      orgName: json['org_name'],
      orgCategoryId: json['org_category_id'],
      orgSubcategoryId: json['org_subcategory_id'],
      orgAddress: json['org_address'],
      orgArea: json['org_area'],
      orgCity: json['org_city'],
      orgState: json['org_state'],
      orgPincode: json['org_pincode'],
      orgMobile: json['org_mobile'],
      orgWhatsApp: json['org_whatsapp'],
      orgEmail: json['org_email'],
      orgLogo: "https://members.mumbaimaheshwari.com/api/public/" +json['org_logo'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organisation_offer_discount_id': organisationOfferDiscountId,
      'offer_discount_name': offerDiscountName,
      'offer_description': offerDescription,
      'org_contact_person_name': offerContactPersonName,
      'org_contact_person_name': offerContactPersonMobile,
      'valid_from': validFrom,
      'valid_to': validTo,
      'offer_image': offerImage,
      'org_details_id': orgDetailsID,
      'org_name': orgName,
      'org_category_id': orgCategoryId,
      'org_subcategory_id': orgSubcategoryId,
      'org_address': orgAddress,
      'org_area': orgArea,
      'org_city': orgCity,
      'org_state': orgState,
      'org_pincode': orgPincode,
      'org_mobile': orgMobile,
      'org_whatsapp': orgWhatsApp,
      'org_email': orgEmail,
      'org_logo': orgLogo,
    
    };
  }
}
