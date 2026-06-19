import 'package:mpm/model/PaymentTransactionId/PaymentTransactionIdData.dart';

class PaymentTransactionIdModelClass {
  bool? status;
  String? message;
  PaymentTransactionIdData? data;

  PaymentTransactionIdModelClass({
    this.status,
    this.message,
    this.data,
  });

  factory PaymentTransactionIdModelClass.fromJson(Map<String, dynamic> json) {
    return PaymentTransactionIdModelClass(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? PaymentTransactionIdData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}