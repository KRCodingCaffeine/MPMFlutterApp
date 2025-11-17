class BusinessAddressData {
  String? memberAddressId;
  String? addressType;
  String? flatNo;
  String? address;
  String? areaName;
  String? cityName;
  String? pincode;
  String? stateName;
  String? countryName;

  BusinessAddressData({
    this.memberAddressId,
    this.addressType,
    this.flatNo,
    this.address,
    this.areaName,
    this.cityName,
    this.pincode,
    this.stateName,
    this.countryName,
  });

  BusinessAddressData.fromJson(Map<String, dynamic> json) {
    memberAddressId = json['member_address_id'];
    addressType = json['address_type'];
    flatNo = json['flat_no'];
    address = json['address'];
    areaName = json['area_name'];
    cityName = json['city_name'];
    pincode = json['pincode'];
    stateName = json['state_name'];
    countryName = json['country_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    json['member_address_id'] = memberAddressId;
    json['address_type'] = addressType;
    json['flat_no'] = flatNo;
    json['address'] = address;
    json['area_name'] = areaName;
    json['city_name'] = cityName;
    json['pincode'] = pincode;
    json['state_name'] = stateName;
    json['country_name'] = countryName;

    return json;
  }
}
