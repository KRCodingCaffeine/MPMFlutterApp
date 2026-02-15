import 'AddRequestedLoanEducationData.dart';

class AddRequestedLoanEducationModelClass {
  bool? status;
  int? code;
  String? message;
  AddRequestedLoanEducationData? data;

  AddRequestedLoanEducationModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory AddRequestedLoanEducationModelClass.fromJson(
      Map<String, dynamic> json) {
    return AddRequestedLoanEducationModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? AddRequestedLoanEducationData.fromJson(json['data'])
          : null,
    );
  }
}
