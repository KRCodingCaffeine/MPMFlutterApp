import 'package:mpm/model/EventAttendees/EventAttendeesData.dart';

class EventAttendeesModelClass {
  bool? status;
  String? message;
  List<EventAttendeesData>? data;

  EventAttendeesModelClass({
    this.status,
    this.message,
    this.data,
  });

  factory EventAttendeesModelClass.fromJson(Map<String, dynamic> json) {
    return EventAttendeesModelClass(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List)
          .map((e) => EventAttendeesData.fromJson(e))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}