class DeleteRequestedLoanEducationData {
  String? shikshaApplicantRequestedLoanEducationId;

  DeleteRequestedLoanEducationData.fromJson(
      Map<String, dynamic> json) {
    shikshaApplicantRequestedLoanEducationId =
        json['shiksha_applicant_requested_loan_education_id']
            ?.toString();
  }
}
