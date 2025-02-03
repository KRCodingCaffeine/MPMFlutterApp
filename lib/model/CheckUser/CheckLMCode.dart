import 'package:mpm/model/CheckUser/CheckUserData.dart';

class CheckLMCode {
  bool? status;
  String? message;
  List<CheckUserData>? data;

  CheckLMCode({this.status, this.message, this.data});

  CheckLMCode.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <CheckUserData>[];
      json['data'].forEach((v) {
        data!.add(new CheckUserData.fromJson(v));
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
