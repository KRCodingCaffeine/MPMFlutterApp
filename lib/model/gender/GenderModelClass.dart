import 'package:mpm/model/gender/DataX.dart';

class GenderModelClass {
  bool? status;
  String? message;
  List<DataX>? data;

  GenderModelClass({this.status, this.message, this.data});

  GenderModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <DataX>[];
      json['data'].forEach((v) {
        data!.add(new DataX.fromJson(v));
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
