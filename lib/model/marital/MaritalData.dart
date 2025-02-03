class MaritalData{
  String? id;
  String? maritalStatus;
  String? status;
  Null? createdAt;
  Null? updatedAt;

  MaritalData(
      {this.id,
        this.maritalStatus,
        this.status,
        this.createdAt,
        this.updatedAt});

  MaritalData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    maritalStatus = json['marital_status'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['marital_status'] = this.maritalStatus;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}