class DeleteReceivedLoanData {
  String? shikshaApplicantReceivedLoanId;

  DeleteReceivedLoanData({
    this.shikshaApplicantReceivedLoanId,
  });

  DeleteReceivedLoanData.fromJson(Map<String, dynamic> json) {
    shikshaApplicantReceivedLoanId =
        json['shiksha_applicant_received_loan_id']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      "shiksha_applicant_received_loan_id":
      shikshaApplicantReceivedLoanId,
    };
  }
}
