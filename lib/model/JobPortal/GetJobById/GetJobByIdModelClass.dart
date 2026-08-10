import 'GetJobByIdData.dart';

class GetJobByIdModelClass {
  bool? status;
  int? code;
  String? message;
  GetJobByIdData? data;

  GetJobByIdModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory GetJobByIdModelClass.fromJson(
      Map<String, dynamic> json) {
    return GetJobByIdModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? GetJobByIdData.fromJson(json['data'])
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