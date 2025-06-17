import 'package:mpm/model/Zone/ZoneData.dart';

class ZoneModelClass {
  bool? status;
  String? message;
  List<ZoneData>? data;

  ZoneModelClass({this.status, this.message, this.data});

  ZoneModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <ZoneData>[];
      json['data'].forEach((v) {
        data!.add(ZoneData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
