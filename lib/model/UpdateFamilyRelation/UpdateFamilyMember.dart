import 'package:mpm/model/UpdateFamilyRelation/UpdateFamilyData.dart';

class UpdateFamilyMember {
  bool? status;
  int? code;
  String? message;
  UpdateFamilyData? data;

  UpdateFamilyMember({this.status, this.code, this.message, this.data});

  UpdateFamilyMember.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new UpdateFamilyData.fromJson(json['data']) : null;
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
