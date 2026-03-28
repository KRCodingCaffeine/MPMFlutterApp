class ApplicantPanUploadModelClass {
  final bool status;
  final int code;
  final String message;
  final ApplicantPanData? data;

  ApplicantPanUploadModelClass({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory ApplicantPanUploadModelClass.fromJson(Map<String, dynamic> json) {
    return ApplicantPanUploadModelClass(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? ApplicantPanData.fromJson(json['data']) : null,
    );
  }
}

class ApplicantPanData {
  final String applicantPanCardDocument;

  ApplicantPanData({required this.applicantPanCardDocument});

  factory ApplicantPanData.fromJson(Map<String, dynamic> json) {
    final imageData = json['1'] ?? json;
    return ApplicantPanData(
      applicantPanCardDocument: imageData['applicant_pan_card_document']?.toString() ?? '',
    );
  }
}