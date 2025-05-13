import 'package:mpm/model/AddOfferDiscountData/AddOfferDiscountData.dart';

class Addofferdiscountmodelclass {
  bool? status;
  String? message;
  List<AddOfferDiscountData>? data;

  Addofferdiscountmodelclass({this.status, this.message, this.data});

  factory Addofferdiscountmodelclass.fromJson(Map<String, dynamic> json) {
    return Addofferdiscountmodelclass(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? List<AddOfferDiscountData>.from(
          json['data'].map((x) => AddOfferDiscountData.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.map((x) => x.toJson()).toList(),
  };
}
