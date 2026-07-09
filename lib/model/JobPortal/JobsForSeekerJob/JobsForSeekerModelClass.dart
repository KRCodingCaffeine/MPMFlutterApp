import 'JobsForSeekerFilterData.dart';

class JobsForSeekerModelClass {
  bool? status;

  int? code;

  String? message;

  JobsForSeekerFilterData? data;

  JobsForSeekerModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory JobsForSeekerModelClass.fromJson(
      Map<String, dynamic> json) {
    return JobsForSeekerModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? JobsForSeekerFilterData.fromJson(json['data'])
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