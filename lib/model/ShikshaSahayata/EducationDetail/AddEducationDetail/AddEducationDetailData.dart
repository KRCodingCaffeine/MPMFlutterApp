class AddEducationDetailData {
  String? shikshaApplicantEducationId;
  String? shikshaApplicantId;
  String? standard;
  String? yearOfPassing;
  String? marksInPercentage;
  String? schoolCollegeName;
  String? boardOrUniversity;
  String? createdBy;

  AddEducationDetailData({
    this.shikshaApplicantEducationId,
    this.shikshaApplicantId,
    this.standard,
    this.yearOfPassing,
    this.marksInPercentage,
    this.schoolCollegeName,
    this.boardOrUniversity,
    this.createdBy,
  });

  AddEducationDetailData.fromJson(Map<String, dynamic> json) {
    shikshaApplicantEducationId =
        json['shiksha_applicant_education_id']?.toString();
    shikshaApplicantId =
        json['shiksha_applicant_id']?.toString();
    standard = json['standard']?.toString();
    yearOfPassing = json['year_of_passing']?.toString();
    marksInPercentage =
        json['marks_in_percentage']?.toString();
    schoolCollegeName =
        json['school_college_name']?.toString();
    boardOrUniversity =
        json['board_or_university']?.toString();
    createdBy = json['created_by']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['shiksha_applicant_id'] = shikshaApplicantId;
    data['standard'] = standard;
    data['year_of_passing'] = yearOfPassing;
    data['marks_in_percentage'] = marksInPercentage;
    data['school_college_name'] = schoolCollegeName;
    data['board_or_university'] = boardOrUniversity;
    data['created_by'] = createdBy;
    return data;
  }
}
