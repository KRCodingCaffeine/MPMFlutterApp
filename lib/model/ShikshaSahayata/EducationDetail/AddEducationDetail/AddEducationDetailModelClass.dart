import 'package:mpm/model/ShikshaSahayata/EducationDetail/AddEducationDetail/AddEducationDetailData.dart';

class AddEducationDetailModelClass {
  bool? status;
  int? code;
  String? message;
  AddEducationDetailData? data;

  AddEducationDetailModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory AddEducationDetailModelClass.fromJson(
      Map<String, dynamic> json) {
    return AddEducationDetailModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? AddEducationDetailData.fromJson(json['data'])
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
