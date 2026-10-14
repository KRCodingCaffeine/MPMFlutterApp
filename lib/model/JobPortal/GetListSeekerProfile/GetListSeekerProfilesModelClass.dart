
import 'package:mpm/model/JobPortal/GetListSeekerProfile/GetListSeekerProfilesData.dart';

class GetListSeekerProfilesModelClass {
  bool? status;
  int? code;
  String? message;

  List<GetListSeekerProfilesData>? data;

  int? total;
  int? limit;
  int? offset;

  GetListSeekerProfilesModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
    this.total,
    this.limit,
    this.offset,
  });

  factory GetListSeekerProfilesModelClass.fromJson(
      Map<String, dynamic> json,
      ) {
    return GetListSeekerProfilesModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],

      data: json['data'] != null
          ? (json['data'] as List)
          .where((e) => e is Map)
          .map(
            (e) => GetListSeekerProfilesData.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList()
          : [],

      total: json['total'],
      limit: json['limit'],
      offset: json['offset'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
      'total': total,
      'limit': limit,
      'offset': offset,
    };
  }
}