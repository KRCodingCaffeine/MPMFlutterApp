import 'package:mpm/model/JobPortal/GetAppliedJobsByMemberId/GetAppliedJobsByMemberIdData.dart';

class GetAppliedJobsByMemberIdModelClass {
  bool? status;
  int? code;
  String? message;
  List<GetAppliedJobsByMemberIdData>? data;

  GetAppliedJobsByMemberIdModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory GetAppliedJobsByMemberIdModelClass.fromJson(
      Map<String, dynamic> json) {
    return GetAppliedJobsByMemberIdModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List)
              .map((e) => GetAppliedJobsByMemberIdData.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}
