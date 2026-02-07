import 'UpdateEducationDetailData.dart';

class UpdateEducationDetailModelClass {
  bool? status;
  int? code;
  String? message;
  UpdateEducationDetailData? data;

  UpdateEducationDetailModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory UpdateEducationDetailModelClass.fromJson(
      Map<String, dynamic> json) {
    return UpdateEducationDetailModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? UpdateEducationDetailData.fromJson(json['data'])
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
