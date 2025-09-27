import 'package:mpm/model/UpdateFoodContainer/UpdateFoodContainerData.dart';

class UpdateFoodContainerModelClass {
  final bool? status;
  final String? message;
  final UpdateFoodContainerData? data;

  UpdateFoodContainerModelClass({
    this.status,
    this.message,
    this.data,
  });

  factory UpdateFoodContainerModelClass.fromJson(Map<String, dynamic> json) {
    return UpdateFoodContainerModelClass(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? UpdateFoodContainerData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}