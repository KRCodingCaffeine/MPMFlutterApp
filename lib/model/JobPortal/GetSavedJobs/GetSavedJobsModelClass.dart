import 'package:mpm/model/JobPortal/GetSavedJobs/GetSavedJobsData.dart';

class GetSavedJobsModelClass {
  bool? status;
  int? code;
  String? message;
  List<GetSavedJobsData>? data;
  int? totalCount;

  GetSavedJobsModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
    this.totalCount,
  });

  factory GetSavedJobsModelClass.fromJson(Map<String, dynamic> json) {
    return GetSavedJobsModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message']?.toString(),
      data: json['data'] is List
          ? (json['data'] as List)
              .map((e) => GetSavedJobsData.fromJson(e))
              .toList()
          : [],
      totalCount: int.tryParse(json['total_count']?.toString() ?? ""),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
      'total_count': totalCount,
    };
  }
}
