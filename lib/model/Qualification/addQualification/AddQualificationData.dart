class AddQualificationData{



  String? id;
  String? qualification;
  String? status;
  Null? createdAt;
  Null? updatedAt;

  AddQualificationData(
  {this.id,
  this.qualification,
  this.status,
  this.createdAt,
  this.updatedAt});

  AddQualificationData.fromJson(Map<String, dynamic> json) {
  id = json['id'];
  qualification = json['qualification'];
  status = json['status'];
  createdAt = json['created_at'];
  updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = new Map<String, dynamic>();
  data['id'] = this.id;
  data['qualification'] = this.qualification;
  data['status'] = this.status;
  data['created_at'] = this.createdAt;
  data['updated_at'] = this.updatedAt;
  return data;
  }
  }

