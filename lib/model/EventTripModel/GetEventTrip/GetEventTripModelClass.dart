import 'package:mpm/model/EventTripModel/GetEventTrip/GetEventTripData.dart';

class GetEventTripModelClass {
  bool? status;
  String? message;
  List<GetEventTripData>? data;

  GetEventTripModelClass({this.status, this.message, this.data});

  factory GetEventTripModelClass.fromJson(Map<String, dynamic> json) {
    return GetEventTripModelClass(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List).map((v) => GetEventTripData.fromJson(v)).toList()
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
