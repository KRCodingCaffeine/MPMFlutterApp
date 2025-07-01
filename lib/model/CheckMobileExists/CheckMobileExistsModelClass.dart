import 'package:mpm/model/CheckUser/CheckUserData2.dart';

class CheckMobileModelClass {
  int? code;
  bool? status;
  String? message;
  CheckUserData2? data;

  CheckMobileModelClass({
    this.code,
    this.status,
    this.message,
    this.data,
  });

  CheckMobileModelClass.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? CheckUserData2.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['code'] = code;
    dataMap['status'] = status;
    dataMap['message'] = message;
    if (data != null) {
      dataMap['data'] = data!.toJson();
    }
    return dataMap;
  }
}
