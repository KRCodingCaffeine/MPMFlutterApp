import 'package:mpm/model/UpdatePriceDistribution/UpdatePriceDistributionData.dart';

class UpdatePriceDistributionModelClass {
  final bool? status;
  final String? message;
  final UpdatePriceDistributionData? data;

  UpdatePriceDistributionModelClass({this.status, this.message, this.data});

  factory UpdatePriceDistributionModelClass.fromJson(Map<String, dynamic> json) {
    return UpdatePriceDistributionModelClass(
      status: json['status'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? UpdatePriceDistributionData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}