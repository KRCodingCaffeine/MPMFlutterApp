import 'package:mpm/model/GetSaraswaniPublication/GetSaraswaniPublicationData.dart';

class SaraswaniPublicationModelClass {
  bool? status;
  int? code;
  String? message;
  SaraswaniPublicationData? data;

  SaraswaniPublicationModelClass({this.status, this.code, this.message, this.data});

  factory SaraswaniPublicationModelClass.fromJson(Map<String, dynamic> json) {
    return SaraswaniPublicationModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? SaraswaniPublicationData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    result['status'] = status;
    result['code'] = code;
    result['message'] = message;
    if (data != null) {
      result['data'] = data!.toJson();
    }
    return result;
  }
}
