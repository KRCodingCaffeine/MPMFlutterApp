class AdmissionUploadData {
  final String documentPath;
  final String documentUrl;

  AdmissionUploadData({
    required this.documentPath,
    required this.documentUrl,
  });

  factory AdmissionUploadData.fromJson(Map<String, dynamic> json) {
    return AdmissionUploadData(
      documentPath: json['document_path']?.toString() ?? '',
      documentUrl: json['document_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document_path': documentPath,
      'document_url': documentUrl,
    };
  }
}
