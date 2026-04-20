import 'ApplicantVisaUploadData.dart';

class ApplicantVisaUploadModelClass {
  final bool status;
  final int code;
  final String message;
  final ApplicantVisaUploadData? data;

  ApplicantVisaUploadModelClass({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory ApplicantVisaUploadModelClass.fromJson(Map<String, dynamic> json) {
    return ApplicantVisaUploadModelClass(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ApplicantVisaUploadData.fromJson(json['data'])
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