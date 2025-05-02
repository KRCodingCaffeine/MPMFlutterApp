import 'package:mpm/model/QualificationMain/QualicationMainData.dart';

class QualicationMainModel {
  bool? status;
  String? message;
  List<QualicationMainData>? data;
 // QualicationMainData? data;
  QualicationMainModel({this.status, this.message, this.data});

  QualicationMainModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <QualicationMainData>[];
      json['data'].forEach((v) {
        data!.add(new QualicationMainData.fromJson(v));
      });
    }
    //data = json['data'] != null ? new QualicationMainData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    // if (this.data != null) {
    //   data['data'] = this.data!.toJson();
    // }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
