import 'package:mpm/model/UpdateOccupation/UpdateOccupationData.dart';

class UpdateOccupationModelClass {
  bool? status;
  int? code;
  String? message;
  UpdateOccupationData? data;

  UpdateOccupationModelClass({this.status, this.code, this.message, this.data});

  UpdateOccupationModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null
        ? UpdateOccupationData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['status'] = status;
    map['code'] = code;
    map['message'] = message;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}