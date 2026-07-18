class UpdateMoreOccupationData {
  String? memberOccupationId;
  String? memberId;
  String? companyName;
  String? designation;
  String? startDate;
  String? endDate;
  String? isCurrentEmployment;
  String? roleDescription;
  String? updatedBy;

  UpdateMoreOccupationData({
    this.memberOccupationId,
    this.memberId,
    this.companyName,
    this.designation,
    this.startDate,
    this.endDate,
    this.isCurrentEmployment,
    this.roleDescription,
    this.updatedBy,
  });

  UpdateMoreOccupationData.fromJson(Map<String, dynamic> json) {
    memberOccupationId = json['member_occupation_id']?.toString();
    memberId = json['member_id']?.toString();
    companyName = json['company_name'];
    designation = json['designation'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    isCurrentEmployment = json['is_current_employment']?.toString();
    roleDescription = json['role_description'];
    updatedBy = json['updated_by']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['member_occupation_id'] = memberOccupationId;
    data['member_id'] = memberId;
    data['company_name'] = companyName;
    data['designation'] = designation;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['is_current_employment'] = isCurrentEmployment;
    data['role_description'] = roleDescription;
    data['updated_by'] = updatedBy;

    return data;
  }
}