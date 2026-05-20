import 'package:mpm/model/EventRegistrationConfirmation/EventRegistrationConfirmationData.dart';

class EventRegistrationConfirmationModelClass {
  bool? status;
  String? message;
  EventRegistrationConfirmationData? data;

  EventRegistrationConfirmationModelClass({
    this.status,
    this.message,
    this.data,
  });

  factory EventRegistrationConfirmationModelClass.fromJson(
      Map<String, dynamic> json) {
    return EventRegistrationConfirmationModelClass(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? EventRegistrationConfirmationData.fromJson(json['data'])
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