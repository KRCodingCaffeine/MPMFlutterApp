import 'package:mpm/model/BusinessProfile/GetAllOccupationProduct/GetAllOccupationProductData.dart';

class GetAllOccupationProductsModelClass {
  bool? status;
  int? code;
  String? message;
  List<GetAllOccupationProductData>? data;

  GetAllOccupationProductsModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  GetAllOccupationProductsModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    message = json['message'];

    if (json['data'] != null) {
      data = <GetAllOccupationProductData>[];
      json['data'].forEach((v) {
        data!.add(GetAllOccupationProductData.fromJson(v));
      });
    }
  }
}
