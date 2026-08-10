import 'MemberApplyJobData.dart';

class MemberApplyJobModelClass {
  bool? status;
  int? code;
  String? message;
  MemberApplyJobData? data;

  MemberApplyJobModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory MemberApplyJobModelClass.fromJson(
      Map<String, dynamic> json) {
    return MemberApplyJobModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message']?.toString(),
      data: json['data'] != null
          ? MemberApplyJobData.fromJson(json['data'])
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