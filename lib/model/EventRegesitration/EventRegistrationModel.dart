import 'package:mpm/model/EventRegesitration/EventRegistrationData.dart';

class EventRegistrationModel {
  bool? status;
  String? message;
  List<EventRegistrationData>? data;

  EventRegistrationModel({this.status, this.message, this.data});

  factory EventRegistrationModel.fromJson(Map<String, dynamic> json) {
    return EventRegistrationModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] is List
          ? List<EventRegistrationData>.from(json['data']
          .map((x) => EventRegistrationData.fromJson(x)))
          : [EventRegistrationData.fromJson(json['data'])])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.map((x) => x.toJson()).toList(),
  };
}
