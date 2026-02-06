class UpdateApplicantDetailData {
  String? shikshaApplicantId;
  String? applicantFirstName;
  String? applicantMiddleName;
  String? applicantLastName;
  String? mobile;
  String? email;
  String? landline;
  String? dateOfBirth;
  String? age;
  String? maritalStatusId;
  String? applicantAddress;
  String? applicantCityId;
  String? applicantStateId;
  String? appliedBy;
  String? updatedBy;

  UpdateApplicantDetailData({
    this.shikshaApplicantId,
    this.applicantFirstName,
    this.applicantMiddleName,
    this.applicantLastName,
    this.mobile,
    this.email,
    this.landline,
    this.dateOfBirth,
    this.age,
    this.maritalStatusId,
    this.applicantAddress,
    this.applicantCityId,
    this.applicantStateId,
    this.appliedBy,
    this.updatedBy,
  });

  factory UpdateApplicantDetailData.fromJson(Map<String, dynamic> json) {
    return UpdateApplicantDetailData(
      shikshaApplicantId: json['shiksha_applicant_id']?.toString(),
      applicantFirstName: json['applicant_first_name']?.toString(),
      applicantMiddleName: json['applicant_middle_name']?.toString(),
      applicantLastName: json['applicant_last_name']?.toString(),
      mobile: json['mobile']?.toString(),
      email: json['email']?.toString(),
      landline: json['landline']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      age: json['age']?.toString(),
      maritalStatusId: json['marital_status_id']?.toString(),
      applicantAddress: json['applicant_address']?.toString(),
      applicantCityId: json['applicant_city_id']?.toString(),
      applicantStateId: json['applicant_state_id']?.toString(),
      appliedBy: json['applied_by']?.toString(),
      updatedBy: json['updated_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "shiksha_applicant_id": shikshaApplicantId,
      "applicant_first_name": applicantFirstName,
      "applicant_middle_name": applicantMiddleName,
      "applicant_last_name": applicantLastName,
      "mobile": mobile,
      "email": email,
      "landline": landline,
      "date_of_birth": dateOfBirth,
      "age": age,
      "marital_status_id": maritalStatusId,
      "applicant_address": applicantAddress,
      "applicant_city_id": applicantCityId,
      "applicant_state_id": applicantStateId,
      "applied_by": appliedBy,
      "updated_by": updatedBy,
    };
  }
}
