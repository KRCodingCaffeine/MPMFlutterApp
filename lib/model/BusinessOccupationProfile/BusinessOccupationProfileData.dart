import 'package:mpm/model/BusinessAddress/BusinessAddressData.dart';

class BusinessOccupationProfileData {
  String? memberBusinessOccupationProfileId;
  String? memberId;
  String? memberOccupationId;
  String? businessName;
  String? businessMobile;
  String? businessLandline;
  String? businessEmail;
  String? businessWebsite;
  String? createdBy;
  String? createdAt;
  String? updatedBy;
  String? updatedAt;
  List<BusinessAddressData>? addresses;

  BusinessOccupationProfileData({
    this.memberBusinessOccupationProfileId,
    this.memberId,
    this.memberOccupationId,
    this.businessName,
    this.businessMobile,
    this.businessLandline,
    this.businessEmail,
    this.businessWebsite,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.addresses,
  });

  BusinessOccupationProfileData.fromJson(Map<String, dynamic> json) {
    memberBusinessOccupationProfileId =
    json['member_business_occupation_profile_id'];
    memberId = json['member_id'];
    memberOccupationId = json['member_occupation_id'];
    businessName = json['business_name'];
    businessMobile = json['business_mobile'];
    businessLandline = json['business_landline'];
    businessEmail = json['business_email'];
    businessWebsite = json['business_website'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedBy = json['updated_by'];
    updatedAt = json['updated_at'];

    if (json['addresses'] != null) {
      addresses = <BusinessAddressData>[];
      json['addresses'].forEach((v) {
        addresses!.add(BusinessAddressData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    json['member_business_occupation_profile_id'] =
        memberBusinessOccupationProfileId;
    json['member_id'] = memberId;
    json['member_occupation_id'] = memberOccupationId;
    json['business_name'] = businessName;
    json['business_mobile'] = businessMobile;
    json['business_landline'] = businessLandline;
    json['business_email'] = businessEmail;
    json['business_website'] = businessWebsite;
    json['created_by'] = createdBy;
    json['created_at'] = createdAt;
    json['updated_by'] = updatedBy;
    json['updated_at'] = updatedAt;

    if (addresses != null) {
      json['addresses'] = addresses!.map((v) => v.toJson()).toList();
    }

    return json;
  }
}
