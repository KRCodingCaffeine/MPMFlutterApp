class ConvertToLMModelClass {
  bool? status;
  String? memberId;
  String? message;
  bool? otpSent;

  ConvertToLMModelClass({
    this.status,
    this.memberId,
    this.message,
    this.otpSent,
  });

  factory ConvertToLMModelClass.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['data'];
    final dataMap = data is Map ? Map<String, dynamic>.from(data) : null;
    final otpSent = dataMap?['otp_sent'] ?? json['otp_sent'];

    return ConvertToLMModelClass(
      status: json['status'] is bool
          ? json['status']
          : json['status']?.toString() == 'true',
      memberId: json['member_id']?.toString() ?? dataMap?['member_id']?.toString(),
      message: json['message']?.toString() ?? json['msg']?.toString(),
      otpSent: otpSent == true || otpSent == 1 || otpSent?.toString() == '1' || otpSent?.toString() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'member_id': memberId,
      'message': message,
      'otp_sent': otpSent,
    };
  }
}
