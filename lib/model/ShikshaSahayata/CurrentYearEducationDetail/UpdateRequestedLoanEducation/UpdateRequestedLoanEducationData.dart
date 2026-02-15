class UpdateRequestedLoanEducationData {
  String? shikshaApplicantRequestedLoanEducationId;
  String? admissionFees;
  String? yearlyFees;
  String? examinationFees;
  String? otherExpenses;
  String? totalExpenses;
  String? instituteBankName;
  String? instituteBankAddress;
  String? instituteBankAccountNo;
  String? instituteBankIfscCode;
  String? updatedBy;

  UpdateRequestedLoanEducationData.fromJson(Map<String, dynamic> json) {
    shikshaApplicantRequestedLoanEducationId =
        json['shiksha_applicant_requested_loan_education_id']?.toString();
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
    updatedBy =
        json['updated_by']?.toString();
  }
}
