import 'package:mpm/model/ShikshaSahayata/UpdateFatherDetail/UpdateFatherData.dart';

class UpdateFatherModelClass {
  bool? status;
  int? code;
  String? message;
  UpdateFatherData? data;

  UpdateFatherModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory UpdateFatherModelClass.fromJson(Map<String, dynamic> json) {
    return UpdateFatherModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? UpdateFatherData.fromJson(json['data'])
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
