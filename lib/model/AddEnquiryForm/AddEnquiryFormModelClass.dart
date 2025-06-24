import 'package:mpm/model/AddEnquiryForm/AddEnquiryFormData.dart';

class EnquiryModelClass {
  bool? status;
  String? message;
  List<EnquiryData>? data;

  EnquiryModelClass({this.status, this.message, this.data});

  factory EnquiryModelClass.fromJson(Map<String, dynamic> json) {
    return EnquiryModelClass(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List).map((v) => EnquiryData.fromJson(v)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.map((v) => v.toJson()).toList(),
    };
  }
}
