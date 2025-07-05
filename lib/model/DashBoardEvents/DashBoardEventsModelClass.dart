import 'package:mpm/model/DashBoardEvents/DashBoardEventsData.dart';

class DashboardEventsModelClass {
  bool? status;
  String? message;
  List<DashboardEventData>? data;

  DashboardEventsModelClass({this.status, this.message, this.data});

  DashboardEventsModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = List<DashboardEventData>.from(
        json['data'].map((v) => DashboardEventData.fromJson(v)),
      );
    }
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.map((v) => v.toJson()).toList(),
  };
}
