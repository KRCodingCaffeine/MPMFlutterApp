class CreateApplicantDetailData {
  String? shikshaApplicantId;
  String? id;
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
  String? createdBy;

  CreateApplicantDetailData({
    this.shikshaApplicantId,
    this.id,
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
    this.createdBy,
  });

  CreateApplicantDetailData.fromJson(Map<String, dynamic> json) {
    shikshaApplicantId = json['shiksha_applicant_id']?.toString();
    id = json['id']?.toString();
    applicantFirstName = json['applicant_first_name'];
    applicantMiddleName = json['applicant_middle_name'];
    applicantLastName = json['applicant_last_name'];
    mobile = json['mobile'];
    email = json['email'];
    landline = json['landline'];
    dateOfBirth = json['date_of_birth'];
    age = json['age']?.toString();
    maritalStatusId = json['marital_status_id']?.toString();
    applicantAddress = json['applicant_address'];
    applicantCityId = json['applicant_city_id']?.toString();
    applicantStateId = json['applicant_state_id']?.toString();
    appliedBy = json['applied_by']?.toString();
    createdBy = json['created_by']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['shiksha_applicant_id'] = shikshaApplicantId;
    data['id'] = id;
    data['applicant_first_name'] = applicantFirstName;
    data['applicant_middle_name'] = applicantMiddleName;
    data['applicant_last_name'] = applicantLastName;
    data['mobile'] = mobile;
    data['email'] = email;
    data['landline'] = landline;
    data['date_of_birth'] = dateOfBirth;
    data['age'] = age;
    data['marital_status_id'] = maritalStatusId;
    data['applicant_address'] = applicantAddress;
    data['applicant_city_id'] = applicantCityId;
    data['applicant_state_id'] = applicantStateId;
    data['applied_by'] = appliedBy;
    data['created_by'] = createdBy;

    return data;
  }
}
