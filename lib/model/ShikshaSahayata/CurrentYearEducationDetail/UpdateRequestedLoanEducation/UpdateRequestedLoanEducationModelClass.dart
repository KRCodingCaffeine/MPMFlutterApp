import 'UpdateRequestedLoanEducationData.dart';

class UpdateRequestedLoanEducationModelClass {
  bool? status;
  int? code;
  String? message;
  UpdateRequestedLoanEducationData? data;

  UpdateRequestedLoanEducationModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory UpdateRequestedLoanEducationModelClass.fromJson(
      Map<String, dynamic> json) {
    return UpdateRequestedLoanEducationModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? UpdateRequestedLoanEducationData.fromJson(json['data'])
          : null,
    );
  }
}
