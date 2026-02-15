import 'DeleteRequestedLoanEducationData.dart';

class DeleteRequestedLoanEducationModelClass {
  bool? status;
  int? code;
  String? message;
  DeleteRequestedLoanEducationData? data;

  DeleteRequestedLoanEducationModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory DeleteRequestedLoanEducationModelClass.fromJson(
      Map<String, dynamic> json) {
    return DeleteRequestedLoanEducationModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? DeleteRequestedLoanEducationData.fromJson(json['data'])
          : null,
    );
  }
}
