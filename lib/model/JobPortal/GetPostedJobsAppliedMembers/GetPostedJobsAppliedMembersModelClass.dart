import 'GetPostedJobsAppliedMembersData.dart';

class GetPostedJobsAppliedMembersModelClass {
  bool? status;
  int? code;
  String? message;

  List<GetPostedJobsAppliedMembersData>? data;

  int? totalCount;
  int? totalAppliedCount;

  GetPostedJobsAppliedMembersModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
    this.totalCount,
    this.totalAppliedCount,
  });

  factory GetPostedJobsAppliedMembersModelClass.fromJson(
      Map<String, dynamic> json) {
    return GetPostedJobsAppliedMembersModelClass(
      status: json['status'],
      code: json['code'] is int
          ? json['code']
          : int.tryParse(
              json['code']?.toString() ?? '',
            ),
      message: json['message']?.toString(),
      totalCount: json['total_count'] is int
          ? json['total_count']
          : int.tryParse(
              json['total_count']?.toString() ?? '',
            ),
      totalAppliedCount: json['total_applied_count'] is int
          ? json['total_applied_count']
          : int.tryParse(
              json['total_applied_count']?.toString() ?? '',
            ),
      data: json['data'] != null
          ? List<GetPostedJobsAppliedMembersData>.from(
              json['data'].map(
                (x) => GetPostedJobsAppliedMembersData.fromJson(x),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['status'] = status;
    data['code'] = code;
    data['message'] = message;

    data['total_count'] = totalCount;
    data['total_applied_count'] = totalAppliedCount;

    if (this.data != null) {
      data['data'] = this.data!.map((e) => e.toJson()).toList();
    }

    return data;
  }
}
