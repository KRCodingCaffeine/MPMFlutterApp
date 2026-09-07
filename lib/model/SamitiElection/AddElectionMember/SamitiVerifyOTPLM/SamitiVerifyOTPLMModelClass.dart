class SamitiVerifyOTPLMModelClass {
  bool? status;
  dynamic data;
  bool? emailSent;
  bool? whatsappSent;
  String? redirectUrl;

  SamitiVerifyOTPLMModelClass({
    this.status,
    this.data,
    this.emailSent,
    this.whatsappSent,
    this.redirectUrl,
  });

  factory SamitiVerifyOTPLMModelClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return SamitiVerifyOTPLMModelClass(
      status: json['status'] is bool
          ? json['status']
          : json['status']?.toString() == 'true',
      data: json['data'],
      emailSent: json['email_sent'] is bool
          ? json['email_sent']
          : json['email_sent']?.toString() == 'true',
      whatsappSent: json['whatsapp_sent'] is bool
          ? json['whatsapp_sent']
          : json['whatsapp_sent']?.toString() == 'true',
      redirectUrl: json['redirect_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data,
      'email_sent': emailSent,
      'whatsapp_sent': whatsappSent,
      'redirect_url': redirectUrl,
    };
  }
}
