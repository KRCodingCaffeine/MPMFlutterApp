import 'package:mpm/model/GetLatestSaraswaniPublication/GetLatestSaraswaniPublicationData.dart';

class GetLatestSaraswaniPublicationModelClass {
  bool? status;
  int? code;
  String? message;
  List<GetLatestSaraswaniPublicationData>? data;

  GetLatestSaraswaniPublicationModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory GetLatestSaraswaniPublicationModelClass.fromJson(Map<String, dynamic> json) {
    return GetLatestSaraswaniPublicationModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? List<GetLatestSaraswaniPublicationData>.from(
          json['data'].map((item) => GetLatestSaraswaniPublicationData.fromJson(item)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    result['status'] = status;
    result['code'] = code;
    result['message'] = message;
    if (data != null) {
      result['data'] = data!.map((item) => item.toJson()).toList();
    }
    return result;
  }
}
