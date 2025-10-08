import 'package:mpm/model/EventTripModel/UpdateTraveller/UpdateTravellerData.dart';

class UpdateTravellerModelClass {
  final bool? status;
  final String? message;
  final UpdateTravellerData? data;

  UpdateTravellerModelClass({
    this.status,
    this.message,
    this.data,
  });

  factory UpdateTravellerModelClass.fromJson(Map<String, dynamic> json) {
    return UpdateTravellerModelClass(
      status: json['status'] as bool?,
      message: json['message']?.toString(),
      data: json['data'] != null
          ? UpdateTravellerData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}
