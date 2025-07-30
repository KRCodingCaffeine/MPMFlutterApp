import 'package:mpm/model/GetEventDetailsById/GetEventDetailsByIdData.dart';

class GetEventDetailsByIdModelClass {
  bool? status;
  String? message;
  List<GetEventDetailsByIdData>? data;

  GetEventDetailsByIdModelClass({this.status, this.message, this.data});

  factory GetEventDetailsByIdModelClass.fromJson(Map<String, dynamic> json) {
    return GetEventDetailsByIdModelClass(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List).map((v) => GetEventDetailsByIdData.fromJson(v)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.map((v) => v.toJson()).toList(),
    };
  }
}
