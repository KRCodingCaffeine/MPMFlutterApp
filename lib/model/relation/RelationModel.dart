import 'package:mpm/model/relation/RelationData.dart';

class RelationModel {
  bool? status;
  String? message;
  List<RelationData>? data;

  RelationModel({this.status, this.message, this.data});

  RelationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <RelationData>[];
      json['data'].forEach((v) {
        data!.add(new RelationData.fromJson(v));
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
