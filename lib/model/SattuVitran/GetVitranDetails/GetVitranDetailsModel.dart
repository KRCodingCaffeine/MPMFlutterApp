import 'package:mpm/model/SattuVitran/GetVitranDetails/VitranData.dart';

class GetVitranDetailsModel {
  bool? status;
  int? code;
  String? message;
  VitranData? data;

  GetVitranDetailsModel({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory GetVitranDetailsModel.fromJson(Map<String, dynamic> json) {
    return GetVitranDetailsModel(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? VitranData.fromJson(json['data'])
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