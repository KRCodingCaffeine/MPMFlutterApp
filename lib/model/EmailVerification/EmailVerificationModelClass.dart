class EmailVerificationModelClass {
  bool? status;
  int? code;
  VerificationEmailData? data;

  EmailVerificationModelClass({this.status, this.code, this.data});

  factory EmailVerificationModelClass.fromJson(Map<String, dynamic> json) {
    return EmailVerificationModelClass(
      status: json['status'],
      code: json['code'],
      data: json['data'] != null ? VerificationEmailData.fromJson(json['data']) : null,
    );
  }
}

class VerificationEmailData {
  String? message;

  VerificationEmailData({this.message});

  factory VerificationEmailData.fromJson(Map<String, dynamic> json) {
    return VerificationEmailData(
      message: json['message'],
    );
  }
}