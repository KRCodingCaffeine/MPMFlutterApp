import 'package:mpm/model/Offer/OfferData.dart';

class OfferModelClass {
  bool? status;
  String? message;
  List<OfferData>? data;

  OfferModelClass({this.status, this.message, this.data});

  factory OfferModelClass.fromJson(Map<String, dynamic> json) {
    return OfferModelClass(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List).map((v) => OfferData.fromJson(v)).toList()
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