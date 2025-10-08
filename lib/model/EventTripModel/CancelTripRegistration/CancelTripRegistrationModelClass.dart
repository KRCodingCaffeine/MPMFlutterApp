import 'package:mpm/model/EventTripModel/CancelTripRegistration/CancelTripRegistrationData.dart';

class CancelTripRegistrationModelClass {
  bool? status;
  String? message;
  CancelTripRegistrationData? data;

  CancelTripRegistrationModelClass({
    this.status,
    this.message,
    this.data,
  });

  factory CancelTripRegistrationModelClass.fromJson(Map<String, dynamic> json) {
    return CancelTripRegistrationModelClass(
      status: json['status'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? CancelTripRegistrationData.fromJson(json['data'])
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
