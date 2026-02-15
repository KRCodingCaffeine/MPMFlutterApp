import 'package:mpm/model/ShikshaSahayata/ApplicantDetail/ApplicantRationUpload/ApplicantRationUploadData.dart';

class ApplicantRationUploadModelClass {
  final bool status;
  final int code;
  final String message;
  final ApplicantRationUploadData? data;

  ApplicantRationUploadModelClass({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory ApplicantRationUploadModelClass.fromJson(Map<String, dynamic> json) {
    return ApplicantRationUploadModelClass(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ApplicantRationUploadData.fromJson(json['data'])
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
