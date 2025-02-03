class BloodGroupData {


  String? id;
  String? bloodGroup;
  String? status;
  Null createdAt;
  Null updatedAt;

  BloodGroupData({this.id, this.bloodGroup, this.status, this.createdAt, this.updatedAt});

  BloodGroupData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bloodGroup = json['blood_group'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['blood_group'] = this.bloodGroup;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
