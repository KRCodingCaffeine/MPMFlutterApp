class UpdateOccupationData {
  String? occupationId;
  String? occupationProfessionId;
  String? occupationSpecializationId;
  String? occupationSpecializationSubCategoryId;
  String? occupationSpecializationSubSubCategoryId;
  String? occupationOtherName;
  String? updatedAt;
  String? updatedBy;
  String? memberOccupationId;
  String? memberId;

  UpdateOccupationData({
    this.occupationId,
    this.occupationProfessionId,
    this.occupationSpecializationId,
    this.occupationSpecializationSubCategoryId,
    this.occupationSpecializationSubSubCategoryId,
    this.occupationOtherName,
    this.updatedAt,
    this.updatedBy,
    this.memberOccupationId,
    this.memberId,
  });

  UpdateOccupationData.fromJson(Map<String, dynamic> json) {
    occupationId = json['occupation_id'];
    occupationProfessionId = json['occupation_profession_id'];
    occupationSpecializationId = json['occupation_specialization_id'];
    occupationSpecializationSubCategoryId = json['occupation_specialization_sub_category_id'];
    occupationSpecializationSubSubCategoryId = json['occupation_specialization_sub_sub_category_id'];
    occupationOtherName = json['occupation_other_name'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    memberOccupationId = json['member_occupation_id'].toString();
    memberId = json['member_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['occupation_id'] = occupationId;
    data['occupation_profession_id'] = occupationProfessionId;
    data['occupation_specialization_id'] = occupationSpecializationId;
    data['occupation_specialization_sub_category_id'] = occupationSpecializationSubCategoryId;
    data['occupation_specialization_sub_sub_category_id'] = occupationSpecializationSubSubCategoryId;
    data['occupation_other_name'] = occupationOtherName;
    data['updated_at'] = updatedAt;
    data['updated_by'] = updatedBy;
    data['member_occupation_id'] = memberOccupationId;
    data['member_id'] = memberId;
    return data;
  }
}
