import 'package:mpm/utils/urls.dart';

class OfferData {
  String? organisationOfferDiscountId;
  String? offerDiscountName;
  String? offerDescription;
  String? offerContactPersonName;
  String? offerContactPersonMobile;
  String? validFrom;
  String? validTo;
  String? orgDetailsID;
  String? offerImage;
  String? mpmAuthorizedName;
  String? mpmAuthorizedMobile;
  String? mpmAuthorizedEmail;
  String? orgName;
  String? orgCategoryId;
  String? orgSubcategoryId;
  String? orgAddress;
  String? orgArea;
  String? orgCity;
  String? orgState;
  String? orgPincode;
  String? orgMobile;
  String? orgWhatsApp;
  String? orgEmail;
  String? orgLogo;
  String? categoryName;
  String? subcategoryName;

  OfferData({
    this.organisationOfferDiscountId,
    this.offerDiscountName,
    this.offerDescription,
    this.offerContactPersonName,
    this.offerContactPersonMobile,
    this.validFrom,
    this.validTo,
    this.orgDetailsID,
    this.offerImage,
    this.mpmAuthorizedName,
    this.mpmAuthorizedMobile,
    this.mpmAuthorizedEmail,
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
    this.categoryName,
    this.subcategoryName,
  });

  factory OfferData.fromJson(Map<String, dynamic> json) {
    return OfferData(
      organisationOfferDiscountId: json['organisation_offer_discount_id']?.toString(),
      offerDiscountName: json['offer_discount_name'],
      offerDescription: json['offer_description'],
      offerContactPersonName: json['org_contact_person_name'],
      offerContactPersonMobile: json['org_contact_person_mobile'],
      validFrom: json['valid_from'],
      validTo: json['valid_to'],
      orgDetailsID: json['org_details_id'],
      offerImage: Urls.imagePathUrl + (json['offer_image'] ?? ''),
      mpmAuthorizedName: json['mpm_authorized_name'],
      mpmAuthorizedMobile: json['mpm_authorized_mobile'],
      mpmAuthorizedEmail: json['mpm_authorized_email'],
      orgName: json['org_name'],
      orgCategoryId: json['org_category_id']?.toString(),
      orgSubcategoryId: json['org_subcategory_id']?.toString(),
      orgAddress: json['org_address'],
      orgArea: json['org_area'],
      orgCity: json['org_city'],
      orgState: json['org_state'],
      orgPincode: json['org_pincode'],
      orgMobile: json['org_mobile'],
      orgWhatsApp: json['org_whatsapp'],
      orgEmail: json['org_email'],
      orgLogo: Urls.imagePathUrl + (json['org_logo'] ?? ''),
      categoryName: json['category_name'],
      subcategoryName: json['subcategory_name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['organisation_offer_discount_id'] = organisationOfferDiscountId;
    data['offer_discount_name'] = offerDiscountName;
    data['offer_description'] = offerDescription;
    data['org_contact_person_name'] = offerContactPersonName;
    data['org_contact_person_mobile'] = offerContactPersonMobile;
    data['valid_from'] = validFrom;
    data['valid_to'] = validTo;
    data['org_details_id'] = orgDetailsID;
    data['offer_image'] = offerImage;
    data['mpm_authorized_name'] = mpmAuthorizedName;
    data['mpm_authorized_mobile'] = mpmAuthorizedMobile;
    data['mpm_authorized_email'] = mpmAuthorizedEmail;
    data['org_name'] = orgName;
    data['org_category_id'] = orgCategoryId;
    data['org_subcategory_id'] = orgSubcategoryId;
    data['org_address'] = orgAddress;
    data['org_area'] = orgArea;
    data['org_city'] = orgCity;
    data['org_state'] = orgState;
    data['org_pincode'] = orgPincode;
    data['org_mobile'] = orgMobile;
    data['org_whatsapp'] = orgWhatsApp;
    data['org_email'] = orgEmail;
    data['org_logo'] = orgLogo;
    data['category_name'] = categoryName;
    data['subcategory_name'] = subcategoryName;
    return data;
  }
}