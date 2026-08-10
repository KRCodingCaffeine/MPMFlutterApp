import 'UploadResumeData.dart';

class UploadResumeModelClass {
  final bool status;
  final int code;
  final String message;
  final UploadResumeData? data;

  UploadResumeModelClass({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory UploadResumeModelClass.fromJson(Map<String, dynamic> json) {
    return UploadResumeModelClass(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? UploadResumeData.fromJson(json['data'])
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