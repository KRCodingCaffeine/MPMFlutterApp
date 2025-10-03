import 'package:mpm/model/EventTripModel/GetEventTripDetailsById/GetEventTripDetailsByIdData.dart';

class GetEventTripsDetailsByIdModelClass {
  bool? status;
  String? message;
  List<GetEventTripDetailsByIdData>? data;

  GetEventTripsDetailsByIdModelClass({this.status, this.message, this.data});

  factory GetEventTripsDetailsByIdModelClass.fromJson(Map<String, dynamic> json) {
    return GetEventTripsDetailsByIdModelClass(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List).map((v) => GetEventTripDetailsByIdData.fromJson(v)).toList()
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
