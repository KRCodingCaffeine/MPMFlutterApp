class BusinessAddressData {
  String? memberAddressId;
  String? addressType;
  String? flatNo;
  String? address;
  String? areaName;
  String? cityId;
  String? cityName;
  String? pincode;
  String? stateId;
  String? stateName;
  String? countryId;
  String? countryName;

  BusinessAddressData({
    this.memberAddressId,
    this.addressType,
    this.flatNo,
    this.address,
    this.areaName,
    this.cityId,
    this.cityName,
    this.pincode,
    this.stateId,
    this.stateName,
    this.countryId,
    this.countryName,
  });

  BusinessAddressData.fromJson(Map<String, dynamic> json) {
    memberAddressId = json['member_address_id'];
    addressType = json['address_type'];
    flatNo = json['flat_no'];
    address = json['address'];
    areaName = json['area_name'];
    cityId = json['city_id'];
    cityName = json['city_name'];
    pincode = json['pincode'];
    stateId = json['state_id'];
    stateName = json['state_name'];
    countryId = json['country_id'];
    countryName = json['country_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    json['member_address_id'] = memberAddressId;
    json['address_type'] = addressType;
    json['flat_no'] = flatNo;
    json['address'] = address;
    json['area_name'] = areaName;
    json['city_id'] = cityId;
    json['city_name'] = cityName;
    json['pincode'] = pincode;
    json['state_id'] = stateId;
    json['state_name'] = stateName;
    json['country_id'] = countryId;
    json['country_name'] = countryName;

    return json;
  }
}
