class VerifyOtpLMConversionData {
  String? memberId;
  String? otp;

  VerifyOtpLMConversionData({
    this.memberId,
    this.otp,
  });

  factory VerifyOtpLMConversionData.fromJson(
    Map<String, dynamic> json,
  ) {
    return VerifyOtpLMConversionData(
      memberId: json['member_id']?.toString(),
      otp: json['otp']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'otp': otp,
    };
  }
}
