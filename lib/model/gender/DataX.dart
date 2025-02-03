class DataX {
  String? id;
  String? genderName;
  String? status;
  Null? createdAt;
  Null? updatedAt;

  DataX({this.id, this.genderName, this.status, this.createdAt, this.updatedAt});

  DataX.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    genderName = json['gender_name'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['gender_name'] = this.genderName;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}