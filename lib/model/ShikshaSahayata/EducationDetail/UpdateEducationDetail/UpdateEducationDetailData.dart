class UpdateEducationDetailData {
  String? shikshaApplicantEducationId;
  String? standard;
  String? yearOfPassing;
  String? marksInPercentage;
  String? updatedBy;

  UpdateEducationDetailData({
    this.shikshaApplicantEducationId,
    this.standard,
    this.yearOfPassing,
    this.marksInPercentage,
    this.updatedBy,
  });

  UpdateEducationDetailData.fromJson(Map<String, dynamic> json) {
    shikshaApplicantEducationId =
        json['shiksha_applicant_education_id']?.toString();
    standard = json['standard']?.toString();
    yearOfPassing = json['year_of_passing']?.toString();
    marksInPercentage =
        json['marks_in_percentage']?.toString();
    updatedBy = json['updated_by']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['shiksha_applicant_education_id'] =
        shikshaApplicantEducationId;
    data['standard'] = standard;
    data['year_of_passing'] = yearOfPassing;
    data['marks_in_percentage'] = marksInPercentage;
    data['updated_by'] = updatedBy;
    return data;
  }
}
