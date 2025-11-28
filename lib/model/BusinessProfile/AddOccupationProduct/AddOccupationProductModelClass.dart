import 'package:mpm/model/BusinessProfile/AddOccupationProduct/AddOccupationProductData.dart';

class AddOccupationProductModelClass {
  bool? status;
  int? code;
  String? message;
  AddOccupationProductData? data;

  AddOccupationProductModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory AddOccupationProductModelClass.fromJson(Map<String, dynamic> json) {
    return AddOccupationProductModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? AddOccupationProductData.fromJson(json['data'])
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
