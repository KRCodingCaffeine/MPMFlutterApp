import 'package:mpm/model/OccupationSpec/OccuptionSpecData.dart';

class OccuptionSpectionModel {
  bool? status;
  String? message;
  List<OccuptionSpecData>? data;

  OccuptionSpectionModel({this.status, this.message, this.data});

  OccuptionSpectionModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <OccuptionSpecData>[];
      json['data'].forEach((v) {
        data!.add(new OccuptionSpecData.fromJson(v));
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
