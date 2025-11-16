class Address {
  String? memberAddressId;
  String? memberId;
  String? addressType;
  String? flatNo;
  String? buildingNameId;
  String? buildingName;
  var address;
  String? areaName;
  String? city_id;
  String? stateId;
  String? countryId;
  String? zoneId;
  String? pincode;
  String? createdAt;
  String? createdBy;
  String? updatedAt;
  String? updatedBy;
  String? zoneName;
  String? cityName;
  String? countryName;
  String? stateName;

  Address(
      {this.memberAddressId,
        this.memberId,
        this.addressType,
        this.flatNo,
        this.buildingNameId,
        this.buildingName,
        this.address,
        this.areaName,
        this.city_id,
        this.stateId,
        this.countryId,
        this.zoneId,
        this.pincode,
        this.createdAt,
        this.createdBy,
        this.updatedAt,
        this.updatedBy,
        this.zoneName,
        this.cityName,
        this.countryName,
        this.stateName});

  Address.fromJson(Map<String, dynamic> json) {
    memberAddressId = json['member_address_id'];
    memberId = json['member_id'];
    addressType = json['address_type'];
    flatNo = json['flat_no'];
    buildingNameId = json['building_name_id'] ?? json['building_name'];
    buildingName = json['building_name'];
    address = json['address'];
    areaName = json['area_name'];
    city_id = json['city_id'];
    stateId = json['state_id'];
    countryId = json['country_id'];
    zoneId = json['zone_id'];
    pincode = json['pincode'];
    createdAt = json['created_at'];
    createdBy = json['created_by'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    zoneName = json['zone_name'];
    cityName = json['city_name'];
    countryName = json['country_name'];
    stateName = json['state_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['member_address_id'] = this.memberAddressId;
    data['member_id'] = this.memberId;
    data['address_type'] = this.addressType;
    data['flat_no'] = this.flatNo;
    data['building_name_id'] = this.buildingNameId;
    data['building_name'] = this.buildingName;
    data['address'] = this.address;
    data['area_name'] = this.areaName;
    data['city_id'] = this.city_id;
    data['state_id'] = this.stateId;
    data['country_id'] = this.countryId;
    data['zone_id'] = this.zoneId;
    data['pincode'] = this.pincode;
    data['created_at'] = this.createdAt;
    data['created_by'] = this.createdBy;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    data['zone_name'] = this.zoneName;
    data['city_name'] = this.cityName;
    data['country_name'] = this.countryName;
    data['state_name'] = this.stateName;
    return data;
  }
}
