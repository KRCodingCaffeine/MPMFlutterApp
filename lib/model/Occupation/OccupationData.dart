class OccupationData{
  String? id;
  String? occupation;
  String? status;
  Null? createdAt;
  Null? updatedAt;

  OccupationData({required this.id, required this.occupation, required this.status, required this.createdAt, required this.updatedAt});

  OccupationData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    occupation = json['occupation'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['occupation'] = this.occupation;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }

}