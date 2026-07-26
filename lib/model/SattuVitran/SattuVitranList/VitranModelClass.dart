import 'package:mpm/model/SattuVitran/SattuVitranList/VitranData.dart';

class VitranModelClass {
  bool? status;
  int? code;
  String? message;
  int? total;
  int? limit;
  int? offset;
  List<VitranData>? data;

  VitranModelClass({
    this.status,
    this.code,
    this.message,
    this.total,
    this.limit,
    this.offset,
    this.data,
  });

  factory VitranModelClass.fromJson(Map<String, dynamic> json) {
    return VitranModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      total: json['total'],
      limit: json['limit'],
      offset: json['offset'],
      data: json['data'] != null
          ? (json['data'] as List).map((e) => VitranData.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,
      'total': total,
      'limit': limit,
      'offset': offset,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}
