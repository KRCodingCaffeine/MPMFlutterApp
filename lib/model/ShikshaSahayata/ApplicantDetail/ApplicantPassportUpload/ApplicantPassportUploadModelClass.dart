import 'ApplicantPassportUploadData.dart';

class ApplicantPassportUploadModelClass {
  final bool status;
  final int code;
  final String message;
  final ApplicantPassportUploadData? data;

  ApplicantPassportUploadModelClass({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory ApplicantPassportUploadModelClass.fromJson(Map<String, dynamic> json) {
    return ApplicantPassportUploadModelClass(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ApplicantPassportUploadData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "code": code,
      "message": message,
      "data": data?.toJson(),
    };
  }
}