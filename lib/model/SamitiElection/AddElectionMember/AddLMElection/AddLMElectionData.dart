class AddLMElectionData {
  String? candidateType;
  String? memberId;
  String? samitiId;
  String? samitiSubCategoryId;
  String? samitiRoleId;
  String? startYear;
  String? endYear;
  String? createdBy;

  AddLMElectionData({
    this.candidateType,
    this.memberId,
    this.samitiId,
    this.samitiSubCategoryId,
    this.samitiRoleId,
    this.startYear,
    this.endYear,
    this.createdBy,
  });

  factory AddLMElectionData.fromJson(
    Map<String, dynamic> json,
  ) {
    return AddLMElectionData(
      candidateType: json['candidate_type']?.toString(),
      memberId: json['member_id']?.toString(),
      samitiId: json['samiti_id']?.toString(),
      samitiSubCategoryId: json['samiti_sub_category_id']?.toString(),
      samitiRoleId: json['samiti_role_id']?.toString(),
      startYear: json['start_year']?.toString(),
      endYear: json['end_year']?.toString(),
      createdBy: json['created_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'candidate_type': candidateType,
      'member_id': memberId,
      'samiti_id': samitiId,
      'samiti_sub_category_id': samitiSubCategoryId,
      'samiti_role_id': samitiRoleId,
      'start_year': startYear,
      'end_year': endYear,
      'created_by': createdBy,
    };
  }
}
