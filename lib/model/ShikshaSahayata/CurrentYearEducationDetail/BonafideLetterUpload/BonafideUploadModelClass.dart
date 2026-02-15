import 'BonafideUploadData.dart';

class BonafideUploadModelClass {
  final bool status;
  final int code;
  final String message;
  final BonafideUploadData? data;

  BonafideUploadModelClass({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory BonafideUploadModelClass.fromJson(Map<String, dynamic> json) {
    return BonafideUploadModelClass(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? BonafideUploadData.fromJson(json['data'])
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
