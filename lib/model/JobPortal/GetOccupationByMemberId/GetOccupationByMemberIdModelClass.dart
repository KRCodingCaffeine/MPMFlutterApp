import 'package:mpm/model/JobPortal/GetOccupationByMemberId/GetOccupationByMemberIdData.dart';

class GetOccupationByMemberIdModelClass {
  bool? status;
  int? code;
  String? message;
  List<GetOccupationByMemberIdData>? data;
  int? totalCount;

  GetOccupationByMemberIdModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
    this.totalCount,
  });

  factory GetOccupationByMemberIdModelClass.fromJson(Map<String, dynamic> json) {
    return GetOccupationByMemberIdModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      totalCount: json['total_count'],
      data: json['data'] != null
          ? List<GetOccupationByMemberIdData>.from(
          json['data'].map((x) => GetOccupationByMemberIdData.fromJson(x)))
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