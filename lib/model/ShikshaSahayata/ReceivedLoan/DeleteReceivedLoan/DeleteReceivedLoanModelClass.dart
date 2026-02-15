import 'DeleteReceivedLoanData.dart';

class DeleteReceivedLoanModelClass {
  bool? status;
  int? code;
  String? message;
  DeleteReceivedLoanData? data;

  DeleteReceivedLoanModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory DeleteReceivedLoanModelClass.fromJson(
      Map<String, dynamic> json) {
    return DeleteReceivedLoanModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? DeleteReceivedLoanData.fromJson(json['data'])
          : null,
    );
  }
}
