class ZoneData {
  String? id;
  String? countryId;
  String? stateId;
  String? cityId;
  String? zoneName;
  String? status;
  String? createdAt;
  String? updatedAt;

  ZoneData({
    this.id,
    this.countryId,
    this.stateId,
    this.cityId,
    this.zoneName,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  ZoneData.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    countryId = json['country_id'].toString();
    stateId = json['state_id'].toString();
    cityId = json['city_id'].toString();
    zoneName = json['zone_name'];
    status = json['status'].toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['country_id'] = countryId;
    data['state_id'] = stateId;
    data['city_id'] = cityId;
    data['zone_name'] = zoneName;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
