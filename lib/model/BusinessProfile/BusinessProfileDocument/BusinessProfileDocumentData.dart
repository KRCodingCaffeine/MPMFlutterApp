class BusinessProfileDocumentData {
  final String documentPath;
  final String documentUrl;

  BusinessProfileDocumentData({
    required this.documentPath,
    required this.documentUrl,
  });

  factory BusinessProfileDocumentData.fromJson(Map<String, dynamic> json) {
    return BusinessProfileDocumentData(
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
