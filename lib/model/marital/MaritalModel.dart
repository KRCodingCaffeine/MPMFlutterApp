import 'package:mpm/model/marital/MaritalData.dart';

class MaritalModel {
  bool? status;
  String? message;
  List<MaritalData>? data;

  MaritalModel({this.status, this.message, this.data});

  MaritalModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <MaritalData>[];
      json['data'].forEach((v) {
        data!.add(new MaritalData.fromJson(v));
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