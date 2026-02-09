class AddRequestedLoanEducationData {
  String? shikshaApplicantRequestedLoanEducationId;
  String? shikshaApplicantId;
  String? standard;
  String? schoolCollegeName;
  String? courseDuration;
  String? admissionFees;
  String? yearlyFees;
  String? examinationFees;
  String? otherExpenses;
  String? totalExpenses;
  String? instituteBankName;
  String? instituteBankAddress;
  String? instituteBankAccountNo;
  String? instituteBankIfscCode;
  String? createdBy;

  /// ✅ Constructor for sending data
  AddRequestedLoanEducationData({
    this.shikshaApplicantRequestedLoanEducationId,
    this.shikshaApplicantId,
    this.standard,
    this.schoolCollegeName,
    this.courseDuration,
    this.admissionFees,
    this.yearlyFees,
    this.examinationFees,
    this.otherExpenses,
    this.totalExpenses,
    this.instituteBankName,
    this.instituteBankAddress,
    this.instituteBankAccountNo,
    this.instituteBankIfscCode,
    this.createdBy,
  });

  /// ✅ From JSON (for API response)
  AddRequestedLoanEducationData.fromJson(Map<String, dynamic> json) {
    shikshaApplicantRequestedLoanEducationId =
        json['shiksha_applicant_requested_loan_education_id']?.toString();
    shikshaApplicantId =
        json['shiksha_applicant_id']?.toString();
    standard = json['standard']?.toString();
    schoolCollegeName =
        json['school_college_name']?.toString();
    courseDuration =
        json['course_duration']?.toString();
    admissionFees =
        json['admission_fees']?.toString();
    yearlyFees =
        json['yearly_fees']?.toString();
    examinationFees =
        json['examination_fees']?.toString();
    otherExpenses =
        json['other_expenses']?.toString();
    totalExpenses =
        json['total_expenses']?.toString();
    instituteBankName =
        json['institute_bank_name']?.toString();
    instituteBankAddress =
        json['institute_bank_address']?.toString();
    instituteBankAccountNo =
        json['institute_bank_account_no']?.toString();
    instituteBankIfscCode =
        json['institute_bank_ifsc_code']?.toString();
    createdBy = json['created_by']?.toString();
  }

  /// ✅ To JSON (for API request body)
  Map<String, dynamic> toJson() {
    return {
      "shiksha_applicant_id": shikshaApplicantId,
      "standard": standard,
      "school_college_name": schoolCollegeName,
      "course_duration": courseDuration,
      "admission_fees": admissionFees,
      "yearly_fees": yearlyFees,
      "examination_fees": examinationFees,
      "other_expenses": otherExpenses,
      "total_expenses": totalExpenses,
      "institute_bank_name": instituteBankName,
      "institute_bank_address": instituteBankAddress,
      "institute_bank_account_no": instituteBankAccountNo,
      "institute_bank_ifsc_code": instituteBankIfscCode,
      "created_by": createdBy,
    };
  }
}
