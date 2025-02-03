class Data {
  String? id;
  String? lMCode;
  Null? refrenceId;
  String? countryId;
  String? stateId;
  String? cityId;
  String? zoneId;
  String? pincodeId;
  String? bloodGroupId;
  String? genderId;
  String? maritalStatusId;
  String? email;
  String? mobile;
  String? password;
  String? dob;
  String? buildingName;
  String? fullAddress;
  String? documentType;
  String? image;
  String? isApproved;
  String? status;
  Null? createdAt;
  Null? updatedAt;
Data(
    {this.id,
      this.lMCode,
      this.refrenceId,
      this.countryId,
      this.stateId,
      this.cityId,
      this.zoneId,
      this.pincodeId,
      this.bloodGroupId,
      this.genderId,
      this.maritalStatusId,
      this.email,
      this.mobile,
      this.password,
      this.dob,
      this.buildingName,
      this.fullAddress,
      this.documentType,
      this.image,
      this.isApproved,
      this.status,
      this.createdAt,
      this.updatedAt});

Data.fromJson(Map<String, dynamic> json) {
id = json['id'];
lMCode = json['LM_code'];
refrenceId = json['refrence_id'];
countryId = json['country_id'];
stateId = json['state_id'];
cityId = json['city_id'];
zoneId = json['zone_id'];
pincodeId = json['pincode_id'];
bloodGroupId = json['blood_group_id'];
genderId = json['gender_id'];
maritalStatusId = json['marital_status_id'];
email = json['email'];
mobile = json['mobile'];
password = json['password'];
dob = json['dob'];
buildingName = json['building_name'];
fullAddress = json['full_address'];
documentType = json['document_type'];
image = json['image'];
isApproved = json['is_approved'];
status = json['status'];
createdAt = json['created_at'];
updatedAt = json['updated_at'];
}

Map<String, dynamic> toJson() {
final Map<String, dynamic> data = new Map<String, dynamic>();
data['id'] = this.id;
data['LM_code'] = this.lMCode;
data['refrence_id'] = this.refrenceId;
data['country_id'] = this.countryId;
data['state_id'] = this.stateId;
data['city_id'] = this.cityId;
data['zone_id'] = this.zoneId;
data['pincode_id'] = this.pincodeId;
data['blood_group_id'] = this.bloodGroupId;
data['gender_id'] = this.genderId;
data['marital_status_id'] = this.maritalStatusId;
data['email'] = this.email;
data['mobile'] = this.mobile;
data['password'] = this.password;
data['dob'] = this.dob;
data['building_name'] = this.buildingName;
data['full_address'] = this.fullAddress;
data['document_type'] = this.documentType;
data['image'] = this.image;
data['is_approved'] = this.isApproved;
data['status'] = this.status;
data['created_at'] = this.createdAt;
data['updated_at'] = this.updatedAt;
return data;
}
}