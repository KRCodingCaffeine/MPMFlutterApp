class ApplicantPassportUploadData {
  final String applicantPassportDocument;

  ApplicantPassportUploadData({
    required this.applicantPassportDocument,
  });

  factory ApplicantPassportUploadData.fromJson(Map<String, dynamic> json) {
    // Handling the '1' key or direct object as per your example
    final imageData = json['1'] ?? json;

    return ApplicantPassportUploadData(
      applicantPassportDocument:
      imageData['applicant_passport_document']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicant_passport_document': applicantPassportDocument,
    };
  }
}