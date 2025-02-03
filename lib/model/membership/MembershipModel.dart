import 'package:mpm/model/membership/MemberShipData.dart';

class MembershipModel {
  bool? status;
  String? message;
  List<MemberShipData>? data;

  MembershipModel({this.status, this.message, this.data});

  MembershipModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <MemberShipData>[];
      json['data'].forEach((v) {
        data!.add(new MemberShipData.fromJson(v));
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
