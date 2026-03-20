class LoanRepayment {
  final String? shikshaApplicantLoanRepaymentId;
  final String? shikshaApplicantId;
  final String? loanAmount;
  final String? loanRepaymentAmount;
  final String? loanRepaymentDate;
  final String? loanRepaymentRemarks;
  final String? createdBy;
  final String? createdAt;
  final String? updatedBy;
  final String? updatedAt;

  LoanRepayment({
    this.shikshaApplicantLoanRepaymentId,
    this.shikshaApplicantId,
    this.loanAmount,
    this.loanRepaymentAmount,
    this.loanRepaymentDate,
    this.loanRepaymentRemarks,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  factory LoanRepayment.fromJson(Map<String, dynamic> json) {
    return LoanRepayment(
      shikshaApplicantLoanRepaymentId:
      json['shiksha_applicant_loan_repayment_id']?.toString(),
      shikshaApplicantId:
      json['shiksha_applicant_id']?.toString(),
      loanAmount: json['loan_amount']?.toString(),
      loanRepaymentAmount:
      json['loan_repayment_amount']?.toString(),
      loanRepaymentDate:
      json['loan_repayment_date']?.toString(),
      loanRepaymentRemarks:
      json['loan_repayment_remarks']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedBy: json['updated_by']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shiksha_applicant_loan_repayment_id':
      shikshaApplicantLoanRepaymentId,
      'shiksha_applicant_id': shikshaApplicantId,
      'loan_amount': loanAmount,
      'loan_repayment_amount': loanRepaymentAmount,
      'loan_repayment_date': loanRepaymentDate,
      'loan_repayment_remarks': loanRepaymentRemarks,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_by': updatedBy,
      'updated_at': updatedAt,
    };
  }
}