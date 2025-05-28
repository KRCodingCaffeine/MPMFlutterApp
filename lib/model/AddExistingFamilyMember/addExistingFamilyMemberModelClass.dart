import 'package:mpm/model/AddExistingFamilyMember/addExistingFamilyMemberData.dart';

class Addexistingfamilymembermodelclass {
  bool? status;
  String? message;
  List<AddExistingMemberIntoFamilyData>? data;

  Addexistingfamilymembermodelclass({this.status, this.message, this.data});

  factory Addexistingfamilymembermodelclass.fromJson(Map<String, dynamic> json) {
    return Addexistingfamilymembermodelclass(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? List<AddExistingMemberIntoFamilyData>.from(
          json['data'].map((x) => AddExistingMemberIntoFamilyData.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.map((x) => x.toJson()).toList(),
  };
}
