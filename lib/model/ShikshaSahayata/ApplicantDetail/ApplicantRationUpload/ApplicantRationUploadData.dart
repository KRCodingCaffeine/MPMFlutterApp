class ApplicantRationUploadData {
  final String applicantRationCardDocument;

  ApplicantRationUploadData({
    required this.applicantRationCardDocument,
  });

  factory ApplicantRationUploadData.fromJson(Map<String, dynamic> json) {
    final imageData = json['1'] ?? json;

    return ApplicantRationUploadData(
      applicantRationCardDocument:
      imageData['applicant_ration_card_document']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicant_ration_card_document': applicantRationCardDocument,
    };
  }
}
