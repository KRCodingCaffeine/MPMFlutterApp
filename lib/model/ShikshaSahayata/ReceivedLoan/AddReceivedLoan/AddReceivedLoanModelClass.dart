import 'AddReceivedLoanData.dart';

class AddReceivedLoanModelClass {
  bool? status;
  int? code;
  String? message;
  AddReceivedLoanData? data;

  AddReceivedLoanModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory AddReceivedLoanModelClass.fromJson(Map<String, dynamic> json) {
    return AddReceivedLoanModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? AddReceivedLoanData.fromJson(json['data'])
          : null,
    );
  }
}
