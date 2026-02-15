import 'AddReferredMemberData.dart';

class AddReferredMemberModelClass {
  bool? status;
  int? code;
  String? message;
  AddReferredMemberData? data;

  AddReferredMemberModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory AddReferredMemberModelClass.fromJson(
      Map<String, dynamic> json) {
    return AddReferredMemberModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? AddReferredMemberData.fromJson(json['data'])
          : null,
    );
  }
}
