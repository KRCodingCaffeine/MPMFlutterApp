import 'AddBusinessConnectRequestData.dart';

class AddBusinessConnectRequestModelClass {
  bool? status;
  int? code;
  String? message;
  AddBusinessConnectRequestData? data;

  AddBusinessConnectRequestModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  AddBusinessConnectRequestModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    message = json['message'];

    data = json['data'] != null
        ? AddBusinessConnectRequestData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['status'] = status;
    json['code'] = code;
    json['message'] = message;

    if (data != null) {
      json['data'] = data!.toJson();
    }

    return json;
  }
}
