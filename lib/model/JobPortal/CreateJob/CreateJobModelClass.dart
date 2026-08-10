import 'CreateJobData.dart';

class CreateJobModelClass {
  bool? status;
  int? code;
  String? message;
  CreateJobData? data;

  CreateJobModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory CreateJobModelClass.fromJson(Map<String, dynamic> json) {
    return CreateJobModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? CreateJobData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['code'] = code;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}