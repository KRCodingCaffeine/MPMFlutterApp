import 'DeleteEducationDetailData.dart';

class DeleteEducationDetailModelClass {
  bool? status;
  int? code;
  String? message;
  DeleteEducationDetailData? data;

  DeleteEducationDetailModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory DeleteEducationDetailModelClass.fromJson(
      Map<String, dynamic> json) {
    return DeleteEducationDetailModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? DeleteEducationDetailData.fromJson(json['data'])
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
