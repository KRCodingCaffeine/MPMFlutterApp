class DeleteEducationDetailData {
  String? shikshaApplicantEducationId;

  DeleteEducationDetailData({
    this.shikshaApplicantEducationId,
  });

  DeleteEducationDetailData.fromJson(Map<String, dynamic> json) {
    shikshaApplicantEducationId =
        json['shiksha_applicant_education_id']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['shiksha_applicant_education_id'] =
        shikshaApplicantEducationId;
    return data;
  }
}
