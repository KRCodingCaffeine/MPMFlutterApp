import 'AddSeekerProfileData.dart';

class AddSeekerProfileModelClass {
  bool? status;
  int? code;
  String? message;
  AddSeekerProfileData? data;

  AddSeekerProfileModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory AddSeekerProfileModelClass.fromJson(
      Map<String, dynamic> json) {
    return AddSeekerProfileModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? AddSeekerProfileData.fromJson(json['data'])
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