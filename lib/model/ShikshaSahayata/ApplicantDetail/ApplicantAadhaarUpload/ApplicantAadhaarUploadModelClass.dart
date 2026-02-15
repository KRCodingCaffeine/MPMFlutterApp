import 'ApplicantAadhaarUploadData.dart';

class ApplicantAadhaarUploadModelClass {
  final bool status;
  final int code;
  final String message;
  final ApplicantAadhaarUploadData? data;

  ApplicantAadhaarUploadModelClass({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory ApplicantAadhaarUploadModelClass.fromJson(Map<String, dynamic> json) {
    return ApplicantAadhaarUploadModelClass(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ApplicantAadhaarUploadData.fromJson(json['data'])
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
