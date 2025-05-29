import 'package:mpm/model/ChangeFamilyHead/changeFamilyHeadData.dart';

class ChangeFamilyHeadModelClass {
  bool? status;
  String? message;
  List<ChangeFamilyHeadData>? data;

  ChangeFamilyHeadModelClass({
    this.status,
    this.message,
    this.data,
  });

  factory ChangeFamilyHeadModelClass.fromJson(Map<String, dynamic> json) {
    return ChangeFamilyHeadModelClass(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? List<ChangeFamilyHeadData>.from(
          json['data'].map((x) => ChangeFamilyHeadData.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.map((x) => x.toJson()).toList(),
  };
}
