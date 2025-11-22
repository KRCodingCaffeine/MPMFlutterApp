import 'package:mpm/model/BusinessProfile/UpdateOccupationProduct/UpdateOccupationProductData.dart';

class UpdateOccupationProductModelClass {
  bool? status;
  int? code;
  String? message;
  UpdateOccupationProductData? data;

  UpdateOccupationProductModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory UpdateOccupationProductModelClass.fromJson(Map<String, dynamic> json) {
    return UpdateOccupationProductModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? UpdateOccupationProductData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['code'] = code;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}
