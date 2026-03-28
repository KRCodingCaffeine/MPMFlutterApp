class ApplicantPanUploadData {
  final String applicantPanCardDocument;

  ApplicantPanUploadData({required this.applicantPanCardDocument});

  factory ApplicantPanUploadData.fromJson(Map<String, dynamic> json) {
    final imageData = json['1'] ?? json;
    return ApplicantPanUploadData(
      applicantPanCardDocument: imageData['applicant_pan_card_document']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'applicant_pan_card_document': applicantPanCardDocument};
}