class RequestedLoanEducation {
  final String? shikshaApplicantRequestedLoanEducationId;
  final String? shikshaApplicantId;
  final String? standard;
  final String? schoolCollegeName;
  final String? courseDuration;
  final String? admissionFees;
  final String? yearlyFees;
  final String? examinationFees;
  final String? otherExpenses;
  final String? totalExpenses;
  final String? instituteBankName;
  final String? instituteBankAddress;
  final String? instituteBankAccountNo;
  final String? instituteBankIfscCode;
  final String? admissionConfirmationLetterDoc;
  final String? bonafideFeesDocument;
  final String? requestedAmount;
  final String? sanctionedAmount;
  final String? sanctionedOn;
  final String? sanctionedUpdatedBy;
  final String? sanctionedUpdatedOn;
  final String? disbursedAmount;
  final String? disbursedOn;
  final String? disbursedUpdatedBy;
  final String? disbursedUpdatedOn;
  final String? createdBy;
  final String? createdAt;
  final String? updatedBy;
  final String? updatedAt;

  RequestedLoanEducation({
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
    this.admissionConfirmationLetterDoc,
    this.bonafideFeesDocument,
    this.requestedAmount,
    this.sanctionedAmount,
    this.sanctionedOn,
    this.sanctionedUpdatedBy,
    this.sanctionedUpdatedOn,
    this.disbursedAmount,
    this.disbursedOn,
    this.disbursedUpdatedBy,
    this.disbursedUpdatedOn,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  factory RequestedLoanEducation.fromJson(Map<String, dynamic> json) {
    return RequestedLoanEducation(
      shikshaApplicantRequestedLoanEducationId:
      json['shiksha_applicant_requested_loan_education_id']?.toString(),
      shikshaApplicantId:
      json['shiksha_applicant_id']?.toString(),
      standard: json['standard']?.toString(),
      schoolCollegeName: json['school_college_name']?.toString(),
      courseDuration: json['course_duration']?.toString(),
      admissionFees: json['admission_fees']?.toString(),
      yearlyFees: json['yearly_fees']?.toString(),
      examinationFees: json['examination_fees']?.toString(),
      otherExpenses: json['other_expenses']?.toString(),
      totalExpenses: json['total_expenses']?.toString(),
      instituteBankName: json['institute_bank_name']?.toString(),
      instituteBankAddress: json['institute_bank_address']?.toString(),
      instituteBankAccountNo: json['institute_bank_account_no']?.toString(),
      instituteBankIfscCode: json['institute_bank_ifsc_code']?.toString(),
      admissionConfirmationLetterDoc:
      json['admision_confirmation_letter_doc']?.toString(),
      bonafideFeesDocument:
      json['bonafide_fees_document']?.toString(),
      requestedAmount: json['requested_amount']?.toString(),
      sanctionedAmount: json['sanctioned_amount']?.toString(),
      sanctionedOn: json['sanctioned_on']?.toString(),
      sanctionedUpdatedBy: json['sanctioned_updated_by']?.toString(),
      sanctionedUpdatedOn: json['sanctioned_updated_on']?.toString(),
      disbursedAmount: json['disbursed_amount']?.toString(),
      disbursedOn: json['disbursed_on']?.toString(),
      disbursedUpdatedBy: json['disbursed_updated_by']?.toString(),
      disbursedUpdatedOn: json['disbursed_updated_on']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedBy: json['updated_by']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shiksha_applicant_requested_loan_education_id':
      shikshaApplicantRequestedLoanEducationId,
      'shiksha_applicant_id': shikshaApplicantId,
      'standard': standard,
      'school_college_name': schoolCollegeName,
      'course_duration': courseDuration,
      'admission_fees': admissionFees,
      'yearly_fees': yearlyFees,
      'examination_fees': examinationFees,
      'other_expenses': otherExpenses,
      'total_expenses': totalExpenses,
      'institute_bank_name': instituteBankName,
      'institute_bank_address': instituteBankAddress,
      'institute_bank_account_no': instituteBankAccountNo,
      'institute_bank_ifsc_code': instituteBankIfscCode,
      'admision_confirmation_letter_doc': admissionConfirmationLetterDoc,
      'bonafide_fees_document': bonafideFeesDocument,
      'requested_amount': requestedAmount,
      'sanctioned_amount': sanctionedAmount,
      'sanctioned_on': sanctionedOn,
      'sanctioned_updated_by': sanctionedUpdatedBy,
      'sanctioned_updated_on': sanctionedUpdatedOn,
      'disbursed_amount': disbursedAmount,
      'disbursed_on': disbursedOn,
      'disbursed_updated_by': disbursedUpdatedBy,
      'disbursed_updated_on': disbursedUpdatedOn,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_by': updatedBy,
      'updated_at': updatedAt,
    };
  }
}
