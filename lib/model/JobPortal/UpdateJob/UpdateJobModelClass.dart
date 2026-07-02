import 'UpdateJobData.dart';

class UpdateJobModelClass {
  bool? status;
  int? code;
  String? message;
  UpdateJobData? data;

  UpdateJobModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory UpdateJobModelClass.fromJson(Map<String, dynamic> json) {
    return UpdateJobModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? UpdateJobData.fromJson(json['data'])
          : null,
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