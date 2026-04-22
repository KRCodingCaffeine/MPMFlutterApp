import 'UpdateEducationData.dart';

class UpdateEducationModelClass {
  bool? status;
  int? code;
  String? message;
  UpdateEducationData? data;

  UpdateEducationModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory UpdateEducationModelClass.fromJson(Map<String, dynamic> json) {
    return UpdateEducationModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? UpdateEducationData.fromJson(json['data'])
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