import 'package:mpm/model/ShikshaSahayata/ApplicantDetail/UpdateApplicantDetail/UpdateApplicantDetailData.dart';

class UpdateApplicantDetailModelClass {
  bool? status;
  int? code;
  String? message;
  UpdateApplicantDetailData? data;

  UpdateApplicantDetailModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory UpdateApplicantDetailModelClass.fromJson(
      Map<String, dynamic> json) {
    return UpdateApplicantDetailModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? UpdateApplicantDetailData.fromJson(json['data'])
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
