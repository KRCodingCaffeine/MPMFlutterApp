import 'MarkSheetUploadData.dart';

class MarkSheetUploadModelClass {
  final bool status;
  final int code;
  final String message;
  final MarkSheetUploadData? data;

  MarkSheetUploadModelClass({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory MarkSheetUploadModelClass.fromJson(Map<String, dynamic> json) {
    return MarkSheetUploadModelClass(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? MarkSheetUploadData.fromJson(json['data'])
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
