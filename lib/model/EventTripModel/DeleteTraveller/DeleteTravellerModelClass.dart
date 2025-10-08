import 'package:mpm/model/EventTripModel/DeleteTraveller/DeleteTravellerData.dart';

class DeleteTravellerModelClass {
  final bool? status;
  final String? message;
  final DeleteTravellerData? data;

  DeleteTravellerModelClass({
    this.status,
    this.message,
    this.data,
  });

  factory DeleteTravellerModelClass.fromJson(Map<String, dynamic> json) {
    return DeleteTravellerModelClass(
      status: json['status'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? DeleteTravellerData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}
