import 'package:mpm/model/Qualification/QualificationData.dart';

class QualificationModel {
  bool? status;
  String? message;
  List<QualificationData>? data;

  QualificationModel({this.status, this.message, this.data});

  QualificationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'
        ''];
    if (json['data'] != null) {
      data = <QualificationData>[];
      json['data'].forEach((v) {
        data!.add(new QualificationData.fromJson(v));
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