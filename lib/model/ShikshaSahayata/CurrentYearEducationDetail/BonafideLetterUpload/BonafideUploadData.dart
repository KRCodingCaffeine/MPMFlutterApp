class BonafideUploadData {
  final String documentPath;
  final String documentUrl;

  BonafideUploadData({
    required this.documentPath,
    required this.documentUrl,
  });

  factory BonafideUploadData.fromJson(Map<String, dynamic> json) {
    return BonafideUploadData(
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
