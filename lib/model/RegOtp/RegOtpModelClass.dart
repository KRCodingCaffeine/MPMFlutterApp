class RegOtpModelClass {
  final bool? status;
  final int? code;
  final Regotpdata? data;

  RegOtpModelClass({this.status, this.code, this.data});

  factory RegOtpModelClass.fromJson(Map<String, dynamic> json) {
    return RegOtpModelClass(
      status: json['status'],
      code: json['code'],
      data: json['data'] != null ? Regotpdata.fromJson(json['data']) : null,
    );
  }
}

class Regotpdata {
  final String? message;
  final String? mobileOtp;
  final String? memberId;
  final String? emailOtp;

  Regotpdata({this.message, this.mobileOtp, this.memberId, this.emailOtp});

  factory Regotpdata.fromJson(Map<String, dynamic> json) {
    return Regotpdata(
      message: json['message'],
      mobileOtp: json['mobile_otp'],
      memberId: json['member_id'],
      emailOtp: json['email_otp'],
    );
  }
}
