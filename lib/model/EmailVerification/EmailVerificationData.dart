class VerificationEmailData {
  bool? status;
  int? code;
  String? message;

  VerificationEmailData({
    this.status,
    this.code,
    this.message,
  });

  factory VerificationEmailData.fromJson(Map<String, dynamic> json) {
    return VerificationEmailData(
      status: json['status'],
      code: json['code'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['code'] = code;
    data['message'] = message;
    return data;
  }
}
