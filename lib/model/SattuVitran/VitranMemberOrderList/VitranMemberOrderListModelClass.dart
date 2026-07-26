import 'package:mpm/model/SattuVitran/VitranMemberOrderList/VitranMemberOrderListData.dart';

class VitranMemberOrderListModelClass {
  bool? status;
  int? code;
  String? message;

  List<VitranMemberOrderListData>? data;

  VitranMemberOrderListModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory VitranMemberOrderListModelClass.fromJson(Map<String, dynamic> json) {
    return VitranMemberOrderListModelClass(
      status: json["status"],
      code: json["code"],
      message: json["message"],
      data: json["data"] != null
          ? (json["data"] as List)
              .map((e) => VitranMemberOrderListData.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "code": code,
      "message": message,
      "data": data?.map((e) => e.toJson()).toList(),
    };
  }
}
