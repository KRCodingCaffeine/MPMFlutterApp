
import 'package:mpm/model/CheckUser/CheckUserData2.dart';

class CheckModel {
  bool? status;
  String? message;
  String? token;
  CheckUserData2? data;

  CheckModel({this.status, this.message, this.token, this.data});

  CheckModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    token = json['token'];
    data = json['data'] != null ? new CheckUserData2.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['token'] = this.token;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}
