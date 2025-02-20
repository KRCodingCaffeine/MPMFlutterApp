class CityData{

  String? id;
  String? countryId;
  String? stateId;
  String? cityName;
  String? status;
  Null? createdAt;
  Null? updatedAt;

  CityData(
      {this.id,
        this.countryId,
        this.stateId,
        this.cityName,
        this.status,
        this.createdAt,
        this.updatedAt});

  CityData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    countryId = json['country_id'];
    stateId = json['state_id'];
    cityName = json['city_name'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['country_id'] = this.countryId;
    data['state_id'] = this.stateId;
    data['city_name'] = this.cityName;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}


