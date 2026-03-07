import 'UpdateJobPortalRoleData.dart';

class UpdateJobPortalRoleModelClass {
  bool? status;
  int? code;
  String? message;
  UpdateJobPortalRoleData? data;

  UpdateJobPortalRoleModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory UpdateJobPortalRoleModelClass.fromJson(Map<String, dynamic> json) {
    return UpdateJobPortalRoleModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? UpdateJobPortalRoleData.fromJson(json['data'])
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