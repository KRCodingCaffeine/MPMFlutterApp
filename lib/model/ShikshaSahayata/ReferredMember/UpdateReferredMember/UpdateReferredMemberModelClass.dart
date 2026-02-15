import 'UpdateReferredMemberData.dart';

class UpdateReferredMemberModelClass {
  bool? status;
  int? code;
  String? message;
  UpdateReferredMemberData? data;

  UpdateReferredMemberModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory UpdateReferredMemberModelClass.fromJson(
      Map<String, dynamic> json) {
    return UpdateReferredMemberModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? UpdateReferredMemberData.fromJson(json['data'])
          : null,
    );
  }
}
