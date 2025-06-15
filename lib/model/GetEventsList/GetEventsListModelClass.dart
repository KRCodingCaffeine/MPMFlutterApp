import 'package:mpm/model/GetEventsList/GetEventsListData.dart';

class EventModelClass {
  bool? status;
  String? message;
  List<EventData>? data;

  EventModelClass({this.status, this.message, this.data});

  factory EventModelClass.fromJson(Map<String, dynamic> json) {
    return EventModelClass(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List).map((v) => EventData.fromJson(v)).toList()
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
