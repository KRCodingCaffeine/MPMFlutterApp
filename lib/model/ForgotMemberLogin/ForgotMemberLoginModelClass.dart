import 'package:mpm/model/ForgotMemberLogin/ForgotMemberLoginData.dart';

class ForgotMemberLoginModelClass {
  final bool? status;
  final int? code;
  final ForgotMemberLoginData? data;

  ForgotMemberLoginModelClass({
    this.status,
    this.code,
    this.data,
  });

  factory ForgotMemberLoginModelClass.fromJson(Map<String, dynamic> json) {
    return ForgotMemberLoginModelClass(
      status: json['status'],
      code: json['code'],
      data: json['data'] != null
          ? ForgotMemberLoginData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['code'] = code;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}
