

import 'package:mpm/model/BusinessProfile/BusinessAddress/BusinessAddressData.dart';

class BusinessAddressModelClass {
  bool? status;
  int? code;
  String? message;
  List<BusinessAddressData>? data;

  BusinessAddressModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  BusinessAddressModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    message = json['message'];

    if (json['data'] != null) {
      data = <BusinessAddressData>[];
      json['data'].forEach((v) {
        data!.add(BusinessAddressData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    json['status'] = status;
    json['code'] = code;
    json['message'] = message;

    if (data != null) {
      json['data'] = data!.map((v) => v.toJson()).toList();
    }

    return json;
  }
}
