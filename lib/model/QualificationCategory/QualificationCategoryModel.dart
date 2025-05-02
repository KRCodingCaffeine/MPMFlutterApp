class QualificationCategoryModel {
  bool? status;
  String? message;
  List<Qualificationcategorydata>? data;

  QualificationCategoryModel({this.status, this.message, this.data});

  QualificationCategoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];

     // data = json['data'] != null ? new Qualificationcategorydata.fromJson(json['data']) : null;
    if (json['data'] != null) {
      data = <Qualificationcategorydata>[];
      json['data'].forEach((v) {
        data!.add(new Qualificationcategorydata.fromJson(v));
      });
    }

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    // if (this.data != null) {
    //   data['data'] = this.data!.toJson();
    // }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Qualificationcategorydata {
  String? id;
  String? qualificationId;
  String? qualificationMainId;
  String? name;
  String? status;
  Null? createdAt;
  Null? updatedAt;

  Qualificationcategorydata(
      {this.id,
        this.qualificationId,
        this.qualificationMainId,
        this.name,
        this.status,
        this.createdAt,
        this.updatedAt});

  Qualificationcategorydata.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    qualificationId = json['qualification_id'];
    qualificationMainId = json['qualification_main_id'];
    name = json['name'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['qualification_id'] = this.qualificationId;
    data['qualification_main_id'] = this.qualificationMainId;
    data['name'] = this.name;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}