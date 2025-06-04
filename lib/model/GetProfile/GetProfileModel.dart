import 'package:mpm/model/GetProfile/GetProfileData.dart';

class GetUserProfileModel {
  final bool? status;
  final int? code;
  final String? message;
  final GetProfileData? data;

  GetUserProfileModel({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory GetUserProfileModel.fromJson(Map<String, dynamic> json) {
    return GetUserProfileModel(
      status: json['status'] as bool?,
      code: json['code'] as int?,
      message: json['message']?.toString(),
      data: json['data'] != null
          ? GetProfileData.fromJson(json['data'] as Map<String, dynamic>)
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
