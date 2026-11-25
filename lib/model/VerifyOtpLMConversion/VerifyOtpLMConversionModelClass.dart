class VerifyOtpLMConversionModelClass {
  bool? status;
  String? message;
  dynamic data;
  bool? paymentLinkSmsSent;
  bool? paymentLinkEmailSent;
  bool? paymentLinkWhatsappSent;

  VerifyOtpLMConversionModelClass({
    this.status,
    this.message,
    this.data,
    this.paymentLinkSmsSent,
    this.paymentLinkEmailSent,
    this.paymentLinkWhatsappSent,
  });

  factory VerifyOtpLMConversionModelClass.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawData = json['data'];
    final dataMap = rawData is Map ? Map<String, dynamic>.from(rawData) : null;

    bool asBool(dynamic value) {
      return value == true || value == 1 || value?.toString() == '1' || value?.toString() == 'true';
    }

    return VerifyOtpLMConversionModelClass(
      status: json['status'] is bool
          ? json['status']
          : json['status']?.toString() == 'true',
      message: json['message']?.toString() ?? json['msg']?.toString(),
      data: rawData,
      paymentLinkSmsSent: asBool(dataMap?['payment_link_sms_sent'] ?? json['payment_link_sms_sent']),
      paymentLinkEmailSent: asBool(dataMap?['payment_link_email_sent'] ?? json['payment_link_email_sent']),
      paymentLinkWhatsappSent: asBool(dataMap?['payment_link_whatsapp_sent'] ?? json['payment_link_whatsapp_sent']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
      'payment_link_sms_sent': paymentLinkSmsSent,
      'payment_link_email_sent': paymentLinkEmailSent,
      'payment_link_whatsapp_sent': paymentLinkWhatsappSent,
    };
  }
}
