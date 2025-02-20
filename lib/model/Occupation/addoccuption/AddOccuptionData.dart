class AddOccuptionData{
  String? occupationId;
  String? occupationProfessionId;
  String? occupationSpecializationId;
  String? occupationOtherName;
  String? updatedAt;
  String? updatedBy;

  AddOccuptionData(
      {this.occupationId,
        this.occupationProfessionId,
        this.occupationSpecializationId,
        this.occupationOtherName,
        this.updatedAt,
        this.updatedBy});

  AddOccuptionData.fromJson(Map<String, dynamic> json) {
    occupationId = json['occupation_id'];
    occupationProfessionId = json['occupation_profession_id'];
    occupationSpecializationId = json['occupation_specialization_id'];
    occupationOtherName = json['occupation_other_name'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['occupation_id'] = this.occupationId;
    data['occupation_profession_id'] = this.occupationProfessionId;
    data['occupation_specialization_id'] = this.occupationSpecializationId;
    data['occupation_other_name'] = this.occupationOtherName;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}