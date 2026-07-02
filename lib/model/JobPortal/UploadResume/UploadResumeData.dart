class UploadResumeData {
  final String? resumePath;

  UploadResumeData({this.resumePath});

  factory UploadResumeData.fromJson(Map<String, dynamic> json) {
    return UploadResumeData(
      resumePath: json['resume']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resume': resumePath,
    };
  }
}