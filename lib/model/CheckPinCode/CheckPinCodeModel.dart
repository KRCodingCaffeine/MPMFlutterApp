import 'package:mpm/model/CheckPinCode/CheckPinCodeData.dart';

class CheckPinCodeModel {
  bool? status;
  String? message;
  Checkpincodedata? data;

  CheckPinCodeModel({this.status, this.message, this.data});

  CheckPinCodeModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Checkpincodedata.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}