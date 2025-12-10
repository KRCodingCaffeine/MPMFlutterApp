class SendBusinessProfileData {
  bool? emailSent;
  bool? smsSent;
  String? smsError;

  SendBusinessProfileData({
    this.emailSent,
    this.smsSent,
    this.smsError,
  });

  SendBusinessProfileData.fromJson(Map<String, dynamic> json) {
    emailSent = json['email_sent'];
    smsSent = json['sms_sent'];
    smsError = json['sms_error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    json['email_sent'] = emailSent;
    json['sms_sent'] = smsSent;
    json['sms_error'] = smsError;

    return json;
  }
}
