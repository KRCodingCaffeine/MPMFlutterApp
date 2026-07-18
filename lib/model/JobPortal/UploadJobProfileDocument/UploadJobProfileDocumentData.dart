class UploadJobProfileDocumentData {
  final String? profileSummaryDocument;

  UploadJobProfileDocumentData({
    this.profileSummaryDocument,
  });

  factory UploadJobProfileDocumentData.fromJson(
      Map<String, dynamic> json) {
    return UploadJobProfileDocumentData(
      profileSummaryDocument:
      (json['profile_summary_document'] ??
          json['document'] ??
          json['file_path'])
          ?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_summary_document': profileSummaryDocument,
    };
  }
}