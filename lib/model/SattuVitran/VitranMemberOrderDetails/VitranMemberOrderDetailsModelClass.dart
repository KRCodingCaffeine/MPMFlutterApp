import 'package:mpm/model/SattuVitran/VitranMemberOrderDetails/VitranMemberOrderDetailsData.dart';

class VitranMemberOrderDetailsModelClass {
  bool? status;
  int? code;
  String? message;

  VitranMemberOrderDetailsData? data;

  VitranMemberOrderDetailsModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory VitranMemberOrderDetailsModelClass.fromJson(
      Map<String, dynamic> json) {
    return VitranMemberOrderDetailsModelClass(
      status: json["status"],
      code: json["code"],
      message: json["message"],
      data: json["data"] != null
          ? VitranMemberOrderDetailsData.fromJson(json["data"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "code": code,
      "message": message,
      "data": data?.toJson(),
    };
  }
}