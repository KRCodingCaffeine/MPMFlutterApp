import 'FatherAnnualIncomeUploadData.dart';

class FatherAnnualIncomeUploadModelClass {
  final bool status;
  final int code;
  final String message;
  final FatherAnnualIncomeUploadData? data;

  FatherAnnualIncomeUploadModelClass({required this.status, required this.code, required this.message, this.data});

  factory FatherAnnualIncomeUploadModelClass.fromJson(Map<String, dynamic> json) {
    return FatherAnnualIncomeUploadModelClass(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? FatherAnnualIncomeUploadData.fromJson(json['data']) : null,
    );
  }
}