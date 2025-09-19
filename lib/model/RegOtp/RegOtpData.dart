class Regotpdata {
  String? mobileOtp;
  String? memberId;
  String? emailOtp;

  Regotpdata({this.mobileOtp, this.memberId, this.emailOtp});

  factory Regotpdata.fromJson(Map<String, dynamic> json) {
    return Regotpdata(
      mobileOtp: json['mobile_otp'],
      memberId: json['member_id'],
      emailOtp: json['email_otp'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['mobile_otp'] = mobileOtp;
    data['member_id'] = memberId;
    data['email_otp'] = emailOtp;
    return data;
  }
}
