class ApplicantVisaUploadData {
  final String applicantVisaDocument;

  ApplicantVisaUploadData({
    required this.applicantVisaDocument,
  });

  factory ApplicantVisaUploadData.fromJson(Map<String, dynamic> json) {
    final imageData = json['1'] ?? json;

    return ApplicantVisaUploadData(
      applicantVisaDocument:
      imageData['applicant_visa_document']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicant_visa_document': applicantVisaDocument,
    };
  }
}