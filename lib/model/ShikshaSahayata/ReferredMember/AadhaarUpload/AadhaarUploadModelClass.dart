import 'AadhaarUploadData.dart';

class AadhaarUploadModelClass {
  final bool status;
  final int code;
  final String message;
  final AadhaarUploadData? data;

  AadhaarUploadModelClass({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory AadhaarUploadModelClass.fromJson(Map<String, dynamic> json) {
    return AadhaarUploadModelClass(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? AadhaarUploadData.fromJson(json['data'])
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
