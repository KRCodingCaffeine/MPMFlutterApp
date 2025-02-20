class BusinessInfo {
  String? membersBusinessInfoId;
  String? memberId;
  String? organisationName;
  String? officePhone;
  String? businessEmail;
  String? website;
  String? correspondenceAddress;
  String? memberAddressId;
  String? createdAt;
  String? createdBy;

  String? addressType;
  String? flatNo;
 var buildingNameId;
  String? address;
  String? areaName;
  String? cityId;
  String? stateId;
  String? countryId;
 var zoneId;
  String? pincode;
  var zoneName;
  String? cityName;
  String? countryName;
  String? stateName;

  BusinessInfo(
      {this.membersBusinessInfoId,
        this.memberId,
        this.organisationName,
        this.officePhone,
        this.businessEmail,
        this.website,
        this.correspondenceAddress,
        this.memberAddressId,
        this.createdAt,
        this.createdBy,

        this.addressType,
        this.flatNo,
        this.buildingNameId,
        this.address,
        this.areaName,
        this.cityId,
        this.stateId,
        this.countryId,
        this.zoneId,
        this.pincode,
        this.zoneName,
        this.cityName,
        this.countryName,
        this.stateName});

  BusinessInfo.fromJson(Map<String, dynamic> json) {
    membersBusinessInfoId = json['members_business_info_id'];
    memberId = json['member_id'];
    organisationName = json['organisation_name'];
    officePhone = json['office_phone'];
    businessEmail = json['business_email'];
    website = json['website'];
    correspondenceAddress = json['correspondence_address'];
    memberAddressId = json['member_address_id'];
    createdAt = json['created_at'];
    createdBy = json['created_by'];

    addressType = json['address_type'];
    flatNo = json['flat_no'];
    buildingNameId = json['building_name_id'];
    address = json['address'];
    areaName = json['area_name'];
    cityId = json['city_id'];
    stateId = json['state_id'];
    countryId = json['country_id'];
    zoneId = json['zone_id'];
    pincode = json['pincode'];
    zoneName = json['zone_name'];
    cityName = json['city_name'];
    countryName = json['country_name'];
    stateName = json['state_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['members_business_info_id'] = this.membersBusinessInfoId;
    data['member_id'] = this.memberId;
    data['organisation_name'] = this.organisationName;
    data['office_phone'] = this.officePhone;
    data['business_email'] = this.businessEmail;
    data['website'] = this.website;
    data['correspondence_address'] = this.correspondenceAddress;
    data['member_address_id'] = this.memberAddressId;
    data['created_at'] = this.createdAt;
    data['created_by'] = this.createdBy;

    data['address_type'] = this.addressType;
    data['flat_no'] = this.flatNo;
    data['building_name_id'] = this.buildingNameId;
    data['address'] = this.address;
    data['area_name'] = this.areaName;
    data['city_id'] = this.cityId;
    data['state_id'] = this.stateId;
    data['country_id'] = this.countryId;
    data['zone_id'] = this.zoneId;
    data['pincode'] = this.pincode;
    data['zone_name'] = this.zoneName;
    data['city_name'] = this.cityName;
    data['country_name'] = this.countryName;
    data['state_name'] = this.stateName;
    return data;
  }
}
