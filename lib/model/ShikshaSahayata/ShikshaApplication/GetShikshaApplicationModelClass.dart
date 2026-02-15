import 'package:mpm/model/ShikshaSahayata/ShikshaApplication/ShikshaApplicationData.dart';

class GetShikshaApplicationModelClass {
  final bool? status;
  final int? code;
  final String? message;
  final ShikshaApplicationData? data;

  GetShikshaApplicationModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory GetShikshaApplicationModelClass.fromJson(Map<String, dynamic> json) {
    return GetShikshaApplicationModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message']?.toString(),
      data: json['data'] != null
          ? ShikshaApplicationData.fromJson(json['data'])
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
