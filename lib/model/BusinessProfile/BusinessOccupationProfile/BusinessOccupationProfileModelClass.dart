import 'package:mpm/model/BusinessProfile/BusinessOccupationProfile/BusinessOccupationProfileData.dart';

class BusinessOccupationProfileModelClass {
  bool? status;
  int? code;
  String? message;
  List<BusinessOccupationProfileData>? data;

  BusinessOccupationProfileModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  BusinessOccupationProfileModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    message = json['message'];

    if (json['data'] != null) {
      data = <BusinessOccupationProfileData>[];
      json['data'].forEach((v) {
        data!.add(BusinessOccupationProfileData.fromJson(v));
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
