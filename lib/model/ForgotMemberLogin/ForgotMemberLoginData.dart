class ForgotMemberLoginData {
  final String? fullName;
  final String? mobile;
  final String? email;
  final String? message;

  ForgotMemberLoginData({
    this.fullName,
    this.mobile,
    this.email,
    this.message,
  });

  factory ForgotMemberLoginData.fromJson(Map<String, dynamic> json) {
    return ForgotMemberLoginData(
      fullName: json['full_name'],
      mobile: json['mobile'],
      email: json['email'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['full_name'] = fullName;
    data['mobile'] = mobile;
    data['email'] = email;
    data['message'] = message;
    return data;
  }
}