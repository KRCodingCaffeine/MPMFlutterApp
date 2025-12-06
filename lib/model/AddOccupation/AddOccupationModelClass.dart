import 'package:mpm/model/AddOccupation/AddOccupationData.dart';

class AddOccupationModelClass {
  bool? status;
  int? code;
  String? message;
  AddOccupationData? data;

  AddOccupationModelClass({this.status, this.code, this.message, this.data});

  AddOccupationModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    message = json['message'];

    data = json['data'] != null
        ? AddOccupationData.fromJson(json['data'])
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
