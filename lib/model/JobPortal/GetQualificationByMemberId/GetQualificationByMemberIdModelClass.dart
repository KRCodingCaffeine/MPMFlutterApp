import 'GetQualificationByMemberIdData.dart';

class GetQualificationByMemberIdModelClass {
  bool? status;
  int? code;
  String? message;
  List<GetQualificationByMemberIdData>? data;
  int? totalCount;

  GetQualificationByMemberIdModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
    this.totalCount,
  });

  factory GetQualificationByMemberIdModelClass.fromJson(
      Map<String, dynamic> json) {
    return GetQualificationByMemberIdModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      totalCount: json['total_count'],
      data: json['data'] != null
          ? List<GetQualificationByMemberIdData>.from(
          json['data']
              .map((x) => GetQualificationByMemberIdData.fromJson(x)))
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