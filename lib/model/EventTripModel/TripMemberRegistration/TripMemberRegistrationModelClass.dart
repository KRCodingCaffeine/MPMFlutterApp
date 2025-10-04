import 'package:mpm/model/EventTripModel/TripMemberRegistration/TripMemberRegistrationData.dart';

class TripMemberRegistrationModelClass {
  bool? status;
  String? message;
  List<TripMemberRegistrationData>? data;

  TripMemberRegistrationModelClass({this.status, this.message, this.data});

  factory TripMemberRegistrationModelClass.fromJson(Map<String, dynamic> json) {
    return TripMemberRegistrationModelClass(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List)
          .map((v) => TripMemberRegistrationData.fromJson(v))
          .toList()
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
