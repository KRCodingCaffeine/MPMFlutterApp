import 'BusinessProfileDocumentData.dart';

class BusinessProfileDocumentModelClass {
  final bool status;
  final int code;
  final String message;
  final BusinessProfileDocumentData? data;

  BusinessProfileDocumentModelClass({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory BusinessProfileDocumentModelClass.fromJson(
      Map<String, dynamic> json) {
    return BusinessProfileDocumentModelClass(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? BusinessProfileDocumentData.fromJson(json['data'])
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
