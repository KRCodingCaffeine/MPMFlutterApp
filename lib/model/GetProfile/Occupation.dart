class Occupation {
  String? memberOccupationId;
  String? memberId;
  String? occupationId;
  String? occupationProfessionId;
  String? occupationSpecializationId;
  String? occupationSpecializationSubCategoryId;
  String? occupationSpecializationSubSubCategoryId;
  String? occupationOtherName;
  String? createdAt;
  String? createdBy;
  String? updatedAt;
  String? updatedBy;

  String? occupation;
  String? occupationProfessionName;
  String? specializationName;
  String? specializationSubCategoryName;
  String? specializationSubSubCategoryName;

  Occupation({
    this.memberOccupationId,
    this.memberId,
    this.occupationId,
    this.occupationProfessionId,
    this.occupationSpecializationId,
    this.occupationSpecializationSubCategoryId,
    this.occupationSpecializationSubSubCategoryId,
    this.occupationOtherName,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.occupation,
    this.occupationProfessionName,
    this.specializationName,
    this.specializationSubCategoryName,
    this.specializationSubSubCategoryName,
  });

  Occupation.fromJson(Map<String, dynamic> json) {
    memberOccupationId = json['member_occupation_id'];
    memberId = json['member_id'];
    occupationId = json['occupation_id'];
    occupationProfessionId = json['occupation_profession_id'];
    occupationSpecializationId = json['occupation_specialization_id'];
    occupationSpecializationSubCategoryId =
    json['occupation_specialization_sub_category_id'];
    occupationSpecializationSubSubCategoryId =
    json['occupation_specialization_sub_sub_category_id'];
    occupationOtherName = json['occupation_other_name'];
    createdAt = json['created_at'];
    createdBy = json['created_by'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    occupation = json['occupation'];
    occupationProfessionName = json['occupation_profession_name'];
    specializationName = json['specialization_name'];
    specializationSubCategoryName = json['occupation_specialization_sub_category_name'];
    specializationSubSubCategoryName =
    json['occupation_specialization_sub_sub_category_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['member_occupation_id'] = memberOccupationId;
    data['member_id'] = memberId;
    data['occupation_id'] = occupationId;
    data['occupation_profession_id'] = occupationProfessionId;
    data['occupation_specialization_id'] = occupationSpecializationId;
    data['occupation_specialization_sub_category_id'] =
        occupationSpecializationSubCategoryId;
    data['occupation_specialization_sub_sub_category_id'] =
        occupationSpecializationSubSubCategoryId;
    data['occupation_other_name'] = occupationOtherName;
    data['created_at'] = createdAt;
    data['created_by'] = createdBy;
    data['updated_at'] = updatedAt;
    data['updated_by'] = updatedBy;
    data['occupation'] = occupation;
    data['occupation_profession_name'] = occupationProfessionName;
    data['specialization_name'] = specializationName;
    data['occupation_specialization_sub_category_name'] = specializationSubCategoryName;
    data['occupation_specialization_sub_sub_category_name'] =
        specializationSubSubCategoryName;

    return data;
  }
}
