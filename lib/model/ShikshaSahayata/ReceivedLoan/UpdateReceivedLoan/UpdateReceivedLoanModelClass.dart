import 'UpdateReceivedLoanData.dart';

class UpdateReceivedLoanModelClass {
  bool? status;
  int? code;
  String? message;
  UpdateReceivedLoanData? data;

  UpdateReceivedLoanModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory UpdateReceivedLoanModelClass.fromJson(
      Map<String, dynamic> json) {
    return UpdateReceivedLoanModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? UpdateReceivedLoanData.fromJson(json['data'])
          : null,
    );
  }
}
