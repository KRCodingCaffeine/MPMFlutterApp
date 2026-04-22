
import 'package:mpm/model/UpdateMoreOccupation/UpdateMoreOccupationData.dart';

class UpdateMoreOccupationModelClass {
  bool? status;
  int? code;
  String? message;
  UpdateMoreOccupationData? data;

  UpdateMoreOccupationModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory UpdateMoreOccupationModelClass.fromJson(Map<String, dynamic> json) {
    return UpdateMoreOccupationModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? UpdateMoreOccupationData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['status'] = status;
    data['code'] = code;
    data['message'] = message;

    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }

    return data;
  }
}