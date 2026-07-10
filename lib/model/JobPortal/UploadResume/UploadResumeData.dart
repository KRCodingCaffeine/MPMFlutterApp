class UploadResumeData {
  final String? resumePath;

  UploadResumeData({this.resumePath});

  factory UploadResumeData.fromJson(Map<String, dynamic> json) {
    return UploadResumeData(
      resumePath: (json['resume'] ?? json['resume_path'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resume': resumePath,
    };
  }
}
