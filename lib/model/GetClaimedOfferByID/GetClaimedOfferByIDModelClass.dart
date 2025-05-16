import 'package:mpm/model/GetClaimedOfferByID/GetClaimedOfferData.dart';

class ClaimedOfferModel {
  final bool? status;
  final String? message;
  final List<GetClaimedOfferData>? data;

  ClaimedOfferModel({this.status, this.message, this.data});

  factory ClaimedOfferModel.fromJson(Map<String, dynamic> json) {
    return ClaimedOfferModel(
      status: json['status'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? (json['data'] as List).map((x) => GetClaimedOfferData.fromJson(x)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.map((x) => x.toJson()).toList(),
  };
}