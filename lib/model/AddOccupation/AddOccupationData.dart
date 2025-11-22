class AddOccupationData {
  String? memberId;
  String? occupationId;
  String? occupationProfessionId;
  String? occupationSpecializationId;
  String? occupationSubCategoryId;
  String? occupationOtherName;
  String? createdAt;
  String? createdBy;
  String? memberOccupationId;

  AddOccupationData({
    this.memberId,
    this.occupationId,
    this.occupationProfessionId,
    this.occupationSpecializationId,
    this.occupationSubCategoryId,
    this.occupationOtherName,
    this.createdAt,
    this.createdBy,
    this.memberOccupationId,
  });

  AddOccupationData.fromJson(Map<String, dynamic> json) {
    memberId = json['member_id'];
    occupationId = json['occupation_id'];
    occupationProfessionId = json['occupation_profession_id'];
    occupationSpecializationId = json['occupation_specialization_id'];
    occupationSubCategoryId = json['occupation_specialization_sub_category_id'];
    occupationOtherName = json['occupation_other_name'];
    createdAt = json['created_at'];
    createdBy = json['created_by'];
    memberOccupationId = json['member_occupation_id'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['member_id'] = memberId;
    data['occupation_id'] = occupationId;
    data['occupation_profession_id'] = occupationProfessionId;
    data['occupation_specialization_id'] = occupationSpecializationId;
    data['occupation_specialization_sub_category_id'] = occupationSubCategoryId;
    data['occupation_other_name'] = occupationOtherName;
    data['created_at'] = createdAt;
    data['created_by'] = createdBy;
    data['member_occupation_id'] = memberOccupationId;
    return data;
  }
}
