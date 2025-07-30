import 'package:mpm/model/GetMemberSurname/GetMemberSurnameData.dart';

class MemberSurnameModelClass {
  bool? status;
  String? message;
  List<MemberSurnameData>? data;

  MemberSurnameModelClass({this.status, this.message, this.data});

  MemberSurnameModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <MemberSurnameData>[];
      json['data'].forEach((v) {
        data!.add(MemberSurnameData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
