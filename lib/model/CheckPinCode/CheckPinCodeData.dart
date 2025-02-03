import 'package:mpm/model/CheckPinCode/Building.dart';
import 'package:mpm/model/CheckPinCode/Country.dart';

class Checkpincodedata {
  String? id;
  String? countryId;
  String? stateId;
  String? cityId;
  String? zoneId;
  String? areaName;
  String? pincodeName;
  String? status;
  Null? createdAt;
  Null? updatedAt;
  Country? country;
  Country? state;
  Country? city;
  Country? zone;
  List<Building>? building;

  Checkpincodedata(
      {this.id,
        this.countryId,
        this.stateId,
        this.cityId,
        this.zoneId,
        this.areaName,
        this.pincodeName,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.country,
        this.state,
        this.city,
        this.zone,
        this.building});

  Checkpincodedata.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    countryId = json['country_id'];
    stateId = json['state_id'];
    cityId = json['city_id'];
    zoneId = json['zone_id'];
    areaName = json['area_name'];
    pincodeName = json['pincode_name'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    country =
    json['country'] != null ? new Country.fromJson(json['country']) : null;
    state = json['state'] != null ? new Country.fromJson(json['state']) : null;
    city = json['city'] != null ? new Country.fromJson(json['city']) : null;
    zone = json['zone'] != null ? new Country.fromJson(json['zone']) : null;
    if (json['building'] != null) {
      building = <Building>[];
      json['building'].forEach((v) {
        building!.add(new Building.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['country_id'] = this.countryId;
    data['state_id'] = this.stateId;
    data['city_id'] = this.cityId;
    data['zone_id'] = this.zoneId;
    data['area_name'] = this.areaName;
    data['pincode_name'] = this.pincodeName;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.country != null) {
      data['country'] = this.country!.toJson();
    }
    if (this.state != null) {
      data['state'] = this.state!.toJson();
    }
    if (this.city != null) {
      data['city'] = this.city!.toJson();
    }
    if (this.zone != null) {
      data['zone'] = this.zone!.toJson();
    }
    if (this.building != null) {
      data['building'] = this.building!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}