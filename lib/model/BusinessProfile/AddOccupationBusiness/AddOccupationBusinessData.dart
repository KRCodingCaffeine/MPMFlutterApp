class AddOccupationBusinessData {
  String? memberOccupationId;
  String? businessName;
  String? businessMobile;
  String? businessLandline;
  String? businessEmail;
  String? businessWebsite;
  String? createdBy;
  String? addressType;
  String? flatNo;
  String? address;
  String? areaName;
  String? cityId;
  String? stateId;
  String? countryId;
  String? pincode;
  String? createdAt;

  AddOccupationBusinessData({
    this.memberOccupationId,
    this.businessName,
    this.businessMobile,
    this.businessLandline,
    this.businessEmail,
    this.businessWebsite,
    this.createdBy,
    this.addressType,
    this.flatNo,
    this.address,
    this.areaName,
    this.cityId,
    this.stateId,
    this.countryId,
    this.pincode,
    this.createdAt,
  });

  AddOccupationBusinessData.fromJson(Map<String, dynamic> json) {
    memberOccupationId = json['member_occupation_id']?.toString();
    businessName = json['business_name'];
    businessMobile = json['business_mobile'];
    businessLandline = json['business_landline'];
    businessEmail = json['business_email'];
    businessWebsite = json['business_website'];
    createdBy = json['created_by']?.toString();
    addressType = json['address_type'];
    flatNo = json['flat_no'];
    address = json['address'];
    areaName = json['area_name'];
    cityId = json['city_id']?.toString();
    stateId = json['state_id']?.toString();
    countryId = json['country_id']?.toString();
    pincode = json['pincode'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['member_occupation_id'] = memberOccupationId;
    data['business_name'] = businessName;
    data['business_mobile'] = businessMobile;
    data['business_landline'] = businessLandline;
    data['business_email'] = businessEmail;
    data['business_website'] = businessWebsite;
    data['created_by'] = createdBy;
    data['address_type'] = addressType;
    data['flat_no'] = flatNo;
    data['address'] = address;
    data['area_name'] = areaName;
    data['city_id'] = cityId;
    data['state_id'] = stateId;
    data['country_id'] = countryId;
    data['pincode'] = pincode;
    data['created_at'] = createdAt;
    return data;
  }
}