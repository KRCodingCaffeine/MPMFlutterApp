import 'package:mpm/model/DeviceMapping/DeviceMappingData.dart';

class DeviceMappingModelClass {
  bool? status;
  String? message;
  String? action;
  DeviceMappingData? data;

  DeviceMappingModelClass({this.status, this.message, this.action, this.data});

  factory DeviceMappingModelClass.fromJson(Map<String, dynamic> json) {
    return DeviceMappingModelClass(
      status: json['status'] as bool?,
      message: json['message'] as String?,
      action: json['action'] as String?,
      data: json['data'] != null ? DeviceMappingData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {};
    dataMap['status'] = status;
    dataMap['message'] = message;
    dataMap['action'] = action;
    if (data != null) {
      dataMap['data'] = data!.toJson();
    }
    return dataMap;
  }
}
