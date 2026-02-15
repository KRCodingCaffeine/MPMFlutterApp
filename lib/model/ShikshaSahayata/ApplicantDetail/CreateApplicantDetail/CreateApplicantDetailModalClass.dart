import 'package:mpm/model/ShikshaSahayata/ApplicantDetail/CreateApplicantDetail/CreateApplicantDetailData.dart';

class CreateApplicantDetailModelClass {
  bool? status;
  int? code;
  String? message;
  CreateApplicantDetailData? data;

  CreateApplicantDetailModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory CreateApplicantDetailModelClass.fromJson(
      Map<String, dynamic> json) {
    return CreateApplicantDetailModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? CreateApplicantDetailData.fromJson(json['data'])
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
