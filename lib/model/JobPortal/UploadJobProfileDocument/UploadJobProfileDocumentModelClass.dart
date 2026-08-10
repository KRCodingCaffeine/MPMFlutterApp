import 'UploadJobProfileDocumentData.dart';

class UploadJobProfileDocumentModelClass {
  final bool status;
  final int code;
  final String message;
  final UploadJobProfileDocumentData? data;

  UploadJobProfileDocumentModelClass({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory UploadJobProfileDocumentModelClass.fromJson(
      Map<String, dynamic> json) {
    return UploadJobProfileDocumentModelClass(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? UploadJobProfileDocumentData.fromJson(json['data'])
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