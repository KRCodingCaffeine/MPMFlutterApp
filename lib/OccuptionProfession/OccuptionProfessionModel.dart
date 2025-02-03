import 'package:mpm/OccuptionProfession/OccuptionProfessionData.dart';

class OccuptionProfessionModel {
  bool? status;
  String? message;
  List<OccuptionProfessionData>? data;

  OccuptionProfessionModel({this.status, this.message, this.data});

  OccuptionProfessionModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <OccuptionProfessionData>[];
      json['data'].forEach((v) {
        data!.add(new OccuptionProfessionData.fromJson(v));
      });
    }
  }
}