import 'GetJobAppliedMembersData.dart';

class GetJobAppliedMembersModelClass {
  bool? status;
  int? code;
  String? message;
  int? totalCount;
  List<GetJobAppliedMembersData>? data;

  GetJobAppliedMembersModelClass({
    this.status,
    this.code,
    this.message,
    this.totalCount,
    this.data,
  });

  factory GetJobAppliedMembersModelClass.fromJson(Map<String, dynamic> json) {
    return GetJobAppliedMembersModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      totalCount: json['total_count'],
      data: json['data'] != null
          ? (json['data'] as List)
              .map((e) => GetJobAppliedMembersData.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,
      'total_count': totalCount,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}
