class Occupation {
  String? memberOccupationId;
  String? memberId;
  String? occupationId;
  String? occupationProfessionId;
  String? occupationSpecializationId;
  String? occupationSpecializationSubCategoryId;
  String? occupationOtherName;
  String? createdAt;
  String? createdBy;
  String? updatedAt;
  String? updatedBy;
  String? occupation;
  String? occupationProfessionName;
  String? specializationName;
  String? specializationSubCategoryName;

  Occupation({
    this.memberOccupationId,
    this.memberId,
    this.occupationId,
    this.occupationProfessionId,
    this.occupationSpecializationId,
    this.occupationSpecializationSubCategoryId,
    this.occupationOtherName,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.occupation,
    this.occupationProfessionName,
    this.specializationName,
    this.specializationSubCategoryName,
  });

  Occupation.fromJson(Map<String, dynamic> json) {
    memberOccupationId = json['member_occupation_id'];
    memberId = json['member_id'];
    occupationId = json['occupation_id'];
    occupationProfessionId = json['occupation_profession_id'];
    occupationSpecializationId = json['occupation_specialization_id'];
    occupationSpecializationSubCategoryId = json['occupation_specialization_sub_category_id'];
    occupationOtherName = json['occupation_other_name'];
    createdAt = json['created_at'];
    createdBy = json['created_by'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    occupation = json['occupation'];
    occupationProfessionName = json['occupation_profession_name'];
    specializationName = json['specialization_name'];
    specializationSubCategoryName = json['specialization_sub_category_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['member_occupation_id'] = this.memberOccupationId;
    data['member_id'] = this.memberId;
    data['occupation_id'] = this.occupationId;
    data['occupation_profession_id'] = this.occupationProfessionId;
    data['occupation_specialization_id'] = this.occupationSpecializationId;
    data['occupation_specialization_sub_category_id'] = this.occupationSpecializationSubCategoryId;
    data['occupation_other_name'] = this.occupationOtherName;
    data['created_at'] = this.createdAt;
    data['created_by'] = this.createdBy;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    data['occupation'] = this.occupation;
    data['occupation_profession_name'] = this.occupationProfessionName;
    data['specialization_name'] = this.specializationName;
    data['specialization_sub_category_name'] = this.specializationSubCategoryName;
    return data;
  }
}