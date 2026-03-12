class UpdateEducationData {
  String? memberQualificationId;
  String? memberId;
  String? instituteName;
  String? yearOfPassing;
  String? boardUniversity;
  String? percentageGrade;
  String? isCurrentlyPursuing;
  String? updatedBy;

  UpdateEducationData({
    this.memberQualificationId,
    this.memberId,
    this.instituteName,
    this.yearOfPassing,
    this.boardUniversity,
    this.percentageGrade,
    this.isCurrentlyPursuing,
    this.updatedBy,
  });

  UpdateEducationData.fromJson(Map<String, dynamic> json) {
    memberQualificationId = json['member_qualification_id']?.toString();
    memberId = json['member_id']?.toString();
    instituteName = json['institute_name'];
    yearOfPassing = json['year_of_passing']?.toString();
    boardUniversity = json['board_university'];
    percentageGrade = json['percentage_grade'];
    isCurrentlyPursuing = json['is_currently_pursuing']?.toString();
    updatedBy = json['updated_by']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['member_qualification_id'] = memberQualificationId;
    data['member_id'] = memberId;
    data['institute_name'] = instituteName;
    data['year_of_passing'] = yearOfPassing;
    data['board_university'] = boardUniversity;
    data['percentage_grade'] = percentageGrade;
    data['is_currently_pursuing'] = isCurrentlyPursuing;
    data['updated_by'] = updatedBy;

    return data;
  }
}