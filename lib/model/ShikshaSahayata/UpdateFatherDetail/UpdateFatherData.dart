class UpdateFatherData {
  String? shikshaApplicantId;
  String? applicantFatherName;
  String? applicantMotherName;
  String? fatherEmail;
  String? fatherMobile;
  String? fatherAddress;
  String? fatherCityId;
  String? fatherStateId;
  String? updatedBy;

  UpdateFatherData({
    this.shikshaApplicantId,
    this.applicantFatherName,
    this.applicantMotherName,
    this.fatherEmail,
    this.fatherMobile,
    this.fatherAddress,
    this.fatherCityId,
    this.fatherStateId,
    this.updatedBy,
  });

  UpdateFatherData.fromJson(Map<String, dynamic> json) {
    shikshaApplicantId = json['shiksha_applicant_id']?.toString();
    applicantFatherName = json['applicant_father_name'];
    applicantMotherName = json['applicant_mother_name'];
    fatherEmail = json['father_email'];
    fatherMobile = json['father_mobile'];
    fatherAddress = json['father_address'];
    fatherCityId = json['father_city_id']?.toString();
    fatherStateId = json['father_state_id']?.toString();
    updatedBy = json['updated_by']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['shiksha_applicant_id'] = shikshaApplicantId;
    data['applicant_father_name'] = applicantFatherName;
    data['applicant_mother_name'] = applicantMotherName;
    data['father_email'] = fatherEmail;
    data['father_mobile'] = fatherMobile;
    data['father_address'] = fatherAddress;
    data['father_city_id'] = fatherCityId;
    data['father_state_id'] = fatherStateId;
    data['updated_by'] = updatedBy;
    return data;
  }
}
