import 'GetSeekerProfileData.dart';

class GetSeekerProfileModelClass {
  bool? status;
  int? code;
  String? message;
  GetSeekerProfileData? data;

  GetSeekerProfileModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory GetSeekerProfileModelClass.fromJson(
      Map<String, dynamic> json) {
    return GetSeekerProfileModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? GetSeekerProfileData.fromJson(json['data'])
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