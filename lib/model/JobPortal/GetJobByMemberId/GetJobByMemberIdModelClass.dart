import 'package:mpm/model/JobPortal/GetJobByMemberId/GetJobByMemberIdData.dart';

class GetJobByMemberIdModelClass {
  bool? status;
  int? code;
  String? message;
  List<GetJobByMemberIdData>? data;
  int? totalCount;

  GetJobByMemberIdModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
    this.totalCount,
  });

  factory GetJobByMemberIdModelClass.fromJson(Map<String, dynamic> json) {
    return GetJobByMemberIdModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      totalCount: json['total_count'],
      data: json['data'] != null
          ? List<GetJobByMemberIdData>.from(
          json['data'].map((x) => GetJobByMemberIdData.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['status'] = status;
    data['code'] = code;
    data['message'] = message;
    data['total_count'] = totalCount;

    if (this.data != null) {
      data['data'] = this.data!.map((e) => e.toJson()).toList();
    }

    return data;
  }
}