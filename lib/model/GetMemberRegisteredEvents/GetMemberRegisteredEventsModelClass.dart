import 'package:mpm/model/GetMemberRegisteredEvents/GetMemberRegisteredEventsData.dart';

class EventAttendeesModelClass {
  final bool? status;
  final String? message;
  final List<EventAttendeeData>? data;

  EventAttendeesModelClass({this.status, this.message, this.data});

  factory EventAttendeesModelClass.fromJson(Map<String, dynamic> json) {
    return EventAttendeesModelClass(
      status: json['status'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? (json['data'] as List)
          .map((x) => EventAttendeeData.fromJson(x))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.map((x) => x.toJson()).toList(),
  };
}
