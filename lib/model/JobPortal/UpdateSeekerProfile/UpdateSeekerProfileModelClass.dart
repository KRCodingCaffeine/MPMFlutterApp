import 'UpdateSeekerProfileData.dart';

class UpdateSeekerProfileModelClass {
  bool? status;
  int? code;
  String? message;
  UpdateSeekerProfileData? data;

  UpdateSeekerProfileModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory UpdateSeekerProfileModelClass.fromJson(
      Map<String, dynamic> json) {
    return UpdateSeekerProfileModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? UpdateSeekerProfileData.fromJson(json['data'])
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