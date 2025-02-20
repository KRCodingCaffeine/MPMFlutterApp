import 'package:mpm/model/GetProfile/GetProfileData.dart';

class GetUserProfileModel {
  bool? status;
  int? code;
  String? message;
  GetProfileData? data;

  GetUserProfileModel({this.status, this.code, this.message, this.data});

  GetUserProfileModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new GetProfileData.fromJson(json['data']) : null;
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
