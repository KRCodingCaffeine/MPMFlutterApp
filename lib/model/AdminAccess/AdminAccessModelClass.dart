import 'package:mpm/model/AdminAccess/AdminAccessData.dart';

class AdminAccessModelClass {
  bool? status;
  int? code;
  String? message;
  List<AdminAccessData>? data;

  AdminAccessModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory AdminAccessModelClass.fromJson(Map<String, dynamic> json) {
    return AdminAccessModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List)
          .map((e) => AdminAccessData.fromJson(e))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}