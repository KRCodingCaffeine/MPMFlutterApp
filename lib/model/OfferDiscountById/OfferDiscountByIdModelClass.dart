import 'package:mpm/model/OfferDiscountById/OfferDiscountByIdData.dart';

class Offerdiscountbyidmodelclass {
  bool? status;
  String? message;
  List<OfferDiscountByIdData>? data;

  Offerdiscountbyidmodelclass({this.status, this.message, this.data});

  factory Offerdiscountbyidmodelclass.fromJson(Map<String, dynamic> json) {
    return Offerdiscountbyidmodelclass(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List)
          .map((v) => OfferDiscountByIdData.fromJson(v))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.map((v) => v.toJson()).toList(),
    };
  }
}
