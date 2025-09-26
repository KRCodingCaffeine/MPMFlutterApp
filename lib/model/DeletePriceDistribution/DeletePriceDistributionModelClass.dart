import 'package:mpm/model/DeletePriceDistribution/DeletePriceDistributionData.dart';

class DeletePriceDistributionModelClass {
  final bool? status;
  final String? message;
  final DeletePriceDistributionData? data;

  DeletePriceDistributionModelClass({this.status, this.message, this.data});

  factory DeletePriceDistributionModelClass.fromJson(Map<String, dynamic> json) {
    return DeletePriceDistributionModelClass(
      status: json['status'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? DeletePriceDistributionData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}