import 'package:mpm/model/GetEventsByCoordinator/GetEventsByCoordinatorData.dart';

class GetEventsByCoordinatorModelClass {
  bool? status;
  String? message;
  List<GetEventsByCoordinatorData>? data;

  GetEventsByCoordinatorModelClass({
    this.status,
    this.message,
    this.data,
  });

  factory GetEventsByCoordinatorModelClass.fromJson(
      Map<String, dynamic> json) {
    return GetEventsByCoordinatorModelClass(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List)
          .map((e) => GetEventsByCoordinatorData.fromJson(e))
          .toList()
          : [],
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