import 'package:mpm/model/EventTripModel/AddTraveller/AddTravellerData.dart';

class AddTravellerModelClass {
  bool? status;
  String? message;
  AddTravellerData? data;

  AddTravellerModelClass({this.status, this.message, this.data});

  factory AddTravellerModelClass.fromJson(Map<String, dynamic> json) {
    return AddTravellerModelClass(
      status: json['status'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null ? AddTravellerData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {};
    dataMap['status'] = status;
    dataMap['message'] = message;
    if (data != null) {
      dataMap['data'] = data!.toJson();
    }
    return dataMap;
  }
}
