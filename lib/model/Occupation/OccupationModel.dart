import 'package:mpm/model/Occupation/OccupationData.dart';

class OccupationModel {
  bool? status;
  String? message;
  List<OccupationData>? data;

  OccupationModel({this.status, this.message, this.data});

  OccupationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <OccupationData>[];
      json['data'].forEach((v) {
        data!.add(new OccupationData.fromJson(v));
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
