class OccuptionSpecData{

  String? id;
  String? occupationId;
  String? occupationProfessionId;
  String? name;
  String? status;
  Null? createdAt;
  Null? updatedAt;

  OccuptionSpecData(
  {this.id,
  this.occupationId,
  this.occupationProfessionId,
  this.name,
  this.status,
  this.createdAt,
  this.updatedAt});

  OccuptionSpecData.fromJson(Map<String, dynamic> json) {
  id = json['id']?.toString();
  occupationId = json['occupation_id']?.toString();
  occupationProfessionId = json['occupation_profession_id']?.toString();
  name = json['name']?.toString();
  status = json['status']?.toString();
  createdAt = json['created_at'];
  updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = new Map<String, dynamic>();
  data['id'] = this.id;
  data['occupation_id'] = this.occupationId;
  data['occupation_profession_id'] = this.occupationProfessionId;
  data['name'] = this.name;
  data['status'] = this.status;
  data['created_at'] = this.createdAt;
  data['updated_at'] = this.updatedAt;
  return data;
  }

}