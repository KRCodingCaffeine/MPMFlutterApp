import 'GetSeekerResumeData.dart';

class GetSeekerResumeModelClass {
  bool? status;
  int? code;
  String? message;
  GetSeekerResumeData? data;

  GetSeekerResumeModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory GetSeekerResumeModelClass.fromJson(Map<String, dynamic> json) {
    return GetSeekerResumeModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? GetSeekerResumeData.fromJson(json['data'])
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
