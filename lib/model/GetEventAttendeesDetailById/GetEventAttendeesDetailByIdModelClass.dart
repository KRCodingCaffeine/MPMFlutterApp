import 'package:mpm/model/GetEventAttendeesDetailById/GetEventAttendeesDetailByIdData.dart';

class GetEventAttendeesDetailByIdModelClass {
  final bool? status;
  final String? message;
  final GetEventAttendeesDetailByIdData? data;

  GetEventAttendeesDetailByIdModelClass({this.status, this.message, this.data});

  factory GetEventAttendeesDetailByIdModelClass.fromJson(Map<String, dynamic> json) {
    return GetEventAttendeesDetailByIdModelClass(
      status: json['status'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? GetEventAttendeesDetailByIdData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}