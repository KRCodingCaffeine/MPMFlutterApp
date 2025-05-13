class OfferDiscountByIdData {
  int? organisationOfferDiscountId;
  String? offerDiscountName;
  String? offerDescription;
  String? validFrom;
  String? validTo;
  String? offerImage;
  String? orgName;
  int? orgCategoryId;
  int? orgSubcategoryId;
  String? orgAddress;
  String? orgArea;
  String? orgCity;
  String? orgState;
  String? orgPincode;
  String? orgMobile;
  String? orgEmail;
  String? orgLogo;


  OfferDiscountByIdData({
    this.organisationOfferDiscountId,
    this.offerDiscountName,
    this.offerDescription,
    this.validFrom,
    this.validTo,
    this.offerImage,
    this.orgName,
    this.orgCategoryId,
    this.orgSubcategoryId,
    this.orgAddress,
    this.orgArea,
    this.orgCity,
    this.orgState,
    this.orgPincode,
    this.orgMobile,
    this.orgEmail,
    this.orgLogo,

  });

  factory OfferDiscountByIdData.fromJson(Map<String, dynamic> json) {
    return OfferDiscountByIdData(
      organisationOfferDiscountId: json['organisation_offer_discount_id'],
      offerDiscountName: json['offer_discount_name'],
      offerDescription: json['offer_description'],
      validFrom: json['valid_from'],
      validTo: json['valid_to'],
      offerImage: json['offer_image'],
      orgName: json['org_name'],
      orgCategoryId: json['org_category_id'],
      orgSubcategoryId: json['org_subcategory_id'],
      orgAddress: json['org_address'],
      orgArea: json['org_area'],
      orgCity: json['org_city'],
      orgState: json['org_state'],
      orgPincode: json['org_pincode'],
      orgMobile: json['org_mobile'],
      orgEmail: json['org_email'],
      orgLogo: json['org_logo'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organisation_offer_discount_id': organisationOfferDiscountId,
      'offer_discount_name': offerDiscountName,
      'offer_description': offerDescription,
      'valid_from': validFrom,
      'valid_to': validTo,
      'offer_image': offerImage,
      'org_name': orgName,
      'org_category_id': orgCategoryId,
      'org_subcategory_id': orgSubcategoryId,
      'org_address': orgAddress,
      'org_area': orgArea,
      'org_city': orgCity,
      'org_state': orgState,
      'org_pincode': orgPincode,
      'org_mobile': orgMobile,
      'org_email': orgEmail,
      'org_logo': orgLogo,
    
    };
  }
}
