import 'package:mpm/model/logon/Data.dart';

class LoginModelClass {
  bool? status;
  String? message;
  String? token;
  Data? data;

  LoginModelClass({this.status, this.message, this.token, this.data});

  LoginModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    token = json['token'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
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