import 'AdmissionUploadData.dart';

class AdmissionUploadModelClass {
  final bool status;
  final int code;
  final String message;
  final AdmissionUploadData? data;

  AdmissionUploadModelClass({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory AdmissionUploadModelClass.fromJson(Map<String, dynamic> json) {
    return AdmissionUploadModelClass(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? AdmissionUploadData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,
      'data': data?.toJson(),
    };
  }
}
