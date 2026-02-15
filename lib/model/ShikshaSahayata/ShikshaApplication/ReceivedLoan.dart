class ReceivedLoan {
  final String? shikshaApplicantReceivedLoanId;
  final String? shikshaApplicantId;
  final String? schoolCollegeName;
  final String? courseName;
  final String? yearOfEducation;
  final String? amountReceived;
  final String? amountReceivedOn;
  final String? receivedFrom;
  final String? otherCharityName;
  final String? appliedYearOn;
  final String? createdBy;
  final String? createdAt;
  final String? updatedBy;
  final String? updatedAt;

  ReceivedLoan({
    this.shikshaApplicantReceivedLoanId,
    this.shikshaApplicantId,
    this.schoolCollegeName,
    this.courseName,
    this.yearOfEducation,
    this.amountReceived,
    this.amountReceivedOn,
    this.receivedFrom,
    this.otherCharityName,
    this.appliedYearOn,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  factory ReceivedLoan.fromJson(Map<String, dynamic> json) {
    return ReceivedLoan(
      shikshaApplicantReceivedLoanId:
      json['shiksha_applicant_received_loan_id']?.toString(),
      shikshaApplicantId:
      json['shiksha_applicant_id']?.toString(),
      schoolCollegeName:
      json['school_college_name']?.toString(),
      courseName: json['course_name']?.toString(),
      yearOfEducation:
      json['year_of_education']?.toString(),
      amountReceived:
      json['amount_received']?.toString(),
      amountReceivedOn:
      json['amount_received_on']?.toString(),
      receivedFrom:
      json['received_from']?.toString(),
      otherCharityName:
      json['other_charity_name']?.toString(),
      appliedYearOn:
      json['applied_year_on']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedBy: json['updated_by']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shiksha_applicant_received_loan_id':
      shikshaApplicantReceivedLoanId,
      'shiksha_applicant_id': shikshaApplicantId,
      'school_college_name': schoolCollegeName,
      'course_name': courseName,
      'year_of_education': yearOfEducation,
      'amount_received': amountReceived,
      'amount_received_on': amountReceivedOn,
      'received_from': receivedFrom,
      'other_charity_name': otherCharityName,
      'applied_year_on': appliedYearOn,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_by': updatedBy,
      'updated_at': updatedAt,
    };
  }
}
