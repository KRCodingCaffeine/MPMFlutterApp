import 'SendBusinessProfileData.dart';

class SendBusinessProfileModelClass {
  bool? status;
  int? code;
  String? message;
  SendBusinessProfileData? data;

  SendBusinessProfileModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  SendBusinessProfileModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    message = json['message'];

    data = json['data'] != null
        ? SendBusinessProfileData.fromJson(json['data'])
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
