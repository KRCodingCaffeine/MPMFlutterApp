import 'VitranMemberOrderData.dart';

class VitranMemberOrderModelClass {
  bool? status;
  int? code;
  String? message;
  VitranMemberOrderData? data;

  VitranMemberOrderModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory VitranMemberOrderModelClass.fromJson(
      Map<String, dynamic> json) {
    return VitranMemberOrderModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? VitranMemberOrderData.fromJson(json['data'])
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