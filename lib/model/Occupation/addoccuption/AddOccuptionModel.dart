import 'package:mpm/model/Occupation/addoccuption/AddOccuptionData.dart';

class AddOccuptionModel {
  bool? status;
  int? code;
  String? message;
  AddOccuptionData? data;

  AddOccuptionModel({this.status, this.code, this.message, this.data});

  AddOccuptionModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new AddOccuptionData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}
