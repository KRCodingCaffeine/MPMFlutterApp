class FatherPanUploadData {
  final String applicantFatherPanCardDocument;

  FatherPanUploadData({
    required this.applicantFatherPanCardDocument,
  });

  factory FatherPanUploadData.fromJson(Map<String, dynamic> json) {
    final imageData = json['1'] ?? json;

    return FatherPanUploadData(
      applicantFatherPanCardDocument:
      imageData['applicant_father_pan_card_document']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicant_father_pan_card_document':
      applicantFatherPanCardDocument,
    };
  }
}
