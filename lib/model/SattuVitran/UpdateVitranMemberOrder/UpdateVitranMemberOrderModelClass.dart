import 'UpdateVitranMemberOrderData.dart';

class UpdateVitranMemberOrderModelClass {
  bool? status;
  int? code;
  String? message;
  UpdateVitranMemberOrderData? data;

  UpdateVitranMemberOrderModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory UpdateVitranMemberOrderModelClass.fromJson(
      Map<String, dynamic> json) {
    return UpdateVitranMemberOrderModelClass(
      status: json["status"],
      code: json["code"],
      message: json["message"],
      data: json["data"] != null
          ? UpdateVitranMemberOrderData.fromJson(json["data"])
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
