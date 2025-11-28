import 'package:mpm/model/BusinessProfile/BusinessAddress/BusinessAddressData.dart';

class GetAllBusinessOccupationProfileModelClass {
  bool? status;
  int? code;
  String? message;
  List<BusinessOccupationProfile>? data;

  GetAllBusinessOccupationProfileModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  GetAllBusinessOccupationProfileModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    message = json['message'];

    if (json['data'] != null) {
      data = <BusinessOccupationProfile>[];
      json['data'].forEach((v) {
        data!.add(BusinessOccupationProfile.fromJson(v));
      });
    }
  }
}

class BusinessOccupationProfile {
  String? profileId;
  String? memberId;
  String? memberOccupationId;
  String? businessName;
  String? businessMobile;
  String? businessLandline;
  String? businessEmail;
  String? businessWebsite;
  String? createdAt;
  String? updatedAt;
  List<BusinessAddressData>? addresses;

  BusinessOccupationProfile({
    this.profileId,
    this.memberId,
    this.memberOccupationId,
    this.businessName,
    this.businessMobile,
    this.businessLandline,
    this.businessEmail,
    this.businessWebsite,
    this.createdAt,
    this.updatedAt,
    this.addresses,
  });

  BusinessOccupationProfile.fromJson(Map<String, dynamic> json) {
    profileId = json['member_business_occupation_profile_id'];
    memberId = json['member_id'];
    memberOccupationId = json['member_occupation_id'];
    businessName = json['business_name'];
    businessMobile = json['business_mobile'];
    businessLandline = json['business_landline'];
    businessEmail = json['business_email'];
    businessWebsite = json['business_website'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];

    if (json['addresses'] != null) {
      addresses = <BusinessAddressData>[];
      json['addresses'].forEach((v) {
        addresses!.add(BusinessAddressData.fromJson(v));
      });
    }
  }
}
