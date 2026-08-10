import 'UpdateMemberApplicationStatusData.dart';

class UpdateMemberApplicationStatusModelClass {
  bool? status;
  int? code;
  String? message;
  UpdateMemberApplicationStatusData? data;

  UpdateMemberApplicationStatusModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory UpdateMemberApplicationStatusModelClass.fromJson(
      Map<String, dynamic> json) {
    return UpdateMemberApplicationStatusModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? UpdateMemberApplicationStatusData.fromJson(json['data'])
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
