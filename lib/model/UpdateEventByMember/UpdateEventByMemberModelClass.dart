import 'package:mpm/model/UpdateEventByMember/UpdateEventByMemberData.dart';

class UpdateEventBYMemberModelClass {
  bool? status;
  String? message;
  UpdateEventByMemberData? data;

  UpdateEventBYMemberModelClass({this.status, this.message, this.data});

  factory UpdateEventBYMemberModelClass.fromJson(Map<String, dynamic> json) {
    return UpdateEventBYMemberModelClass(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? UpdateEventByMemberData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}
