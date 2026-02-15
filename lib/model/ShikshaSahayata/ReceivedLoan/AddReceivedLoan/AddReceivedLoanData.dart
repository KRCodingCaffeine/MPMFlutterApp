class AddReceivedLoanData {
  String? shikshaApplicantId;
  String? schoolCollegeName;
  String? courseName;
  String? yearOfEducation;
  String? amountReceived;
  String? receivedFrom;
  String? amountReceivedOn;
  String? appliedYearOn;
  String? otherCharityName;
  String? createdBy;

  AddReceivedLoanData({
    this.shikshaApplicantId,
    this.schoolCollegeName,
    this.courseName,
    this.yearOfEducation,
    this.amountReceived,
    this.receivedFrom,
    this.amountReceivedOn,
    this.appliedYearOn,
    this.otherCharityName,
    this.createdBy,
  });

  AddReceivedLoanData.fromJson(Map<String, dynamic> json) {
    shikshaApplicantId = json['shiksha_applicant_id']?.toString();
    schoolCollegeName = json['school_college_name']?.toString();
    courseName = json['course_name']?.toString();
    yearOfEducation = json['year_of_education']?.toString();
    amountReceived = json['amount_received']?.toString();
    receivedFrom = json['received_from']?.toString();
    amountReceivedOn = json['amount_received_on']?.toString();
    appliedYearOn = json['applied_year_on']?.toString();
    otherCharityName = json['other_charity_name']?.toString();
    createdBy = json['created_by']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      "shiksha_applicant_id": shikshaApplicantId,
      "school_college_name": schoolCollegeName,
      "course_name": courseName,
      "year_of_education": yearOfEducation,
      "amount_received": amountReceived,
      "received_from": receivedFrom,
      "amount_received_on": amountReceivedOn,
      "applied_year_on": appliedYearOn,
      "other_charity_name": otherCharityName,
      "created_by": createdBy,
    };
  }
}
