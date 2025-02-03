class OccuptionProfessionData {
  String? id;
  String? occupationId;
  String? name;
  String? status;
  Null? createdAt;
  Null? updatedAt;

  OccuptionProfessionData(
      {this.id,
        this.occupationId,
        this.name,
        this.status,
        this.createdAt,
        this.updatedAt});

  OccuptionProfessionData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    occupationId = json['occupation_id'];
    name = json['name'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['occupation_id'] = this.occupationId;
    data['name'] = this.name;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}