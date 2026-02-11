class ApplicantAadhaarUploadData {
  final String applicantAadharCardDocument;

  ApplicantAadhaarUploadData({
    required this.applicantAadharCardDocument,
  });

  factory ApplicantAadhaarUploadData.fromJson(Map<String, dynamic> json) {
    final imageData = json['1'] ?? json;

    return ApplicantAadhaarUploadData(
      applicantAadharCardDocument:
      imageData['applicant_aadhar_card_document']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicant_aadhar_card_document': applicantAadharCardDocument,
    };
  }
}
