class QualicationMainData{
  String? id;
  String? qualificationId;
  String? name;
  String? status;
  Null? createdAt;
  Null? updatedAt;

  QualicationMainData(
      {this.id,
        this.qualificationId,
        this.name,
        this.status,
        this.createdAt,
        this.updatedAt});

  QualicationMainData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    qualificationId = json['qualification_id'];
    name = json['name'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['qualification_id'] = this.qualificationId;
    data['name'] = this.name;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }

}