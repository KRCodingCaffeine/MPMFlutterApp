import 'package:mpm/model/GetOfferClaimedByOfferId/getOfferClaimedByOfferIdData.dart';

class Getofferclaimedbyofferidmodelclass {
  bool? status;
  String? message;
  List<GetofferclaimedbyofferidData>? data;

  Getofferclaimedbyofferidmodelclass({this.status, this.message, this.data});

  factory Getofferclaimedbyofferidmodelclass.fromJson(Map<String, dynamic> json) {
    return Getofferclaimedbyofferidmodelclass(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List).map((v) => GetofferclaimedbyofferidData.fromJson(v)).toList()
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