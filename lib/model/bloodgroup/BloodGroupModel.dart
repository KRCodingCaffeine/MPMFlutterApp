import 'package:mpm/model/bloodgroup/BloodData.dart';

class BloodGroupModel {
  bool? status;
  String? message;
  List<BloodGroupData>? data;

  BloodGroupModel({this.status, this.message, this.data});

  BloodGroupModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];

    if (json['data'] != null) {
      data = <BloodGroupData>[];
      json['data'].forEach((v) {
        data!.add(new BloodGroupData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}