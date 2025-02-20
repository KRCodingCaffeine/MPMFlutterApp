import 'package:mpm/model/membersalutation/MemberSalutationData.dart';

class MemberSalutationModel {
  bool? status;
  String? message;
  List<MemberSalutationData>? data;

  MemberSalutationModel({this.status, this.message, this.data});

  MemberSalutationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <MemberSalutationData>[];
      json['data'].forEach((v) {
        data!.add(new MemberSalutationData.fromJson(v));
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
