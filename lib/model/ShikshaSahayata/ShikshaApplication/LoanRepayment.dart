class LoanRepayment {
  final String? shikshaApplicantLoanRepaymentId;
  final String? shikshaApplicantId;
  final String? loanAmount;
  final String? orderId;
  final String? paymentMethod;
  final String? paymentMode;
  final String? transactionId;
  final String? status;
  final String? loanRepaymentAmount;
  final String? loanRepaymentDate;
  final String? chequeDdNumber;
  final String? bankName;
  final String? chequeDdDate;
  final String? gatewayResponse;
  final String? loanRepaymentRemarks;
  final String? paymentStatus;
  final String? createdBy;
  final String? createdAt;
  final String? updatedBy;
  final String? updatedAt;

  LoanRepayment({
    this.shikshaApplicantLoanRepaymentId,
    this.shikshaApplicantId,
    this.loanAmount,
    this.orderId,
    this.paymentMethod,
    this.paymentMode,
    this.transactionId,
    this.status,
    this.loanRepaymentAmount,
    this.loanRepaymentDate,
    this.chequeDdNumber,
    this.bankName,
    this.chequeDdDate,
    this.gatewayResponse,
    this.loanRepaymentRemarks,
    this.paymentStatus,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  factory LoanRepayment.fromJson(Map<String, dynamic> json) {
    return LoanRepayment(
      shikshaApplicantLoanRepaymentId:
          json['shiksha_applicant_loan_repayment_id']?.toString(),
      shikshaApplicantId: json['shiksha_applicant_id']?.toString(),
      loanAmount: json['loan_amount']?.toString(),
      orderId: json['order_id']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      paymentMode: json['payment_mode']?.toString(),
      transactionId: json['transaction_id']?.toString(),
      status: json['status']?.toString(),
      loanRepaymentAmount: json['loan_repayment_amount']?.toString(),
      loanRepaymentDate: json['loan_repayment_date']?.toString(),
      chequeDdNumber: json['cheque_dd_number']?.toString(),
      bankName: json['bank_name']?.toString(),
      chequeDdDate: json['cheque_dd_date']?.toString(),
      gatewayResponse: json['gateway_response']?.toString(),
      loanRepaymentRemarks: json['loan_repayment_remarks']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedBy: json['updated_by']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shiksha_applicant_loan_repayment_id': shikshaApplicantLoanRepaymentId,
      'shiksha_applicant_id': shikshaApplicantId,
      'loan_amount': loanAmount,
      'order_id': orderId,
      'payment_method': paymentMethod,
      'payment_mode': paymentMode,
      'transaction_id': transactionId,
      'status': status,
      'loan_repayment_amount': loanRepaymentAmount,
      'loan_repayment_date': loanRepaymentDate,
      'cheque_dd_number': chequeDdNumber,
      'bank_name': bankName,
      'cheque_dd_date': chequeDdDate,
      'gateway_response': gatewayResponse,
      'loan_repayment_remarks': loanRepaymentRemarks,
      'payment_status': paymentStatus,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_by': updatedBy,
      'updated_at': updatedAt,
    };
  }
}
