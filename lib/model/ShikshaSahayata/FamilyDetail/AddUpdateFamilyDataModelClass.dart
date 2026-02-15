import 'package:mpm/model/ShikshaSahayata/FamilyDetail/AddUpdateFamilyData.dart';

class AddUpdateFamilyDataModelClass {
  bool? status;
  int? code;
  String? message;
  AddUpdateFamilyData? data;

  AddUpdateFamilyDataModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory AddUpdateFamilyDataModelClass.fromJson(
      Map<String, dynamic> json) {
    return AddUpdateFamilyDataModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? AddUpdateFamilyData.fromJson(json['data'])
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
