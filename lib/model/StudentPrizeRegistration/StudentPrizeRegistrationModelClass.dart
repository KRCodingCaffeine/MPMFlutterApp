import 'package:mpm/model/StudentPrizeRegistration/StudentPrizeRegistrationData.dart';

class StudentPrizeRegistrationModelClass {
  bool? status;
  String? message;
  List<StudentPrizeRegistrationData>? data;

  StudentPrizeRegistrationModelClass({this.status, this.message, this.data});

  factory StudentPrizeRegistrationModelClass.fromJson(Map<String, dynamic> json) {
    return StudentPrizeRegistrationModelClass(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] is List
          ? List<StudentPrizeRegistrationData>.from(
          json['data'].map((x) => StudentPrizeRegistrationData.fromJson(x)))
          : [StudentPrizeRegistrationData.fromJson(json['data'])])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.map((x) => x.toJson()).toList(),
  };
}
