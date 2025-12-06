import 'OccuptionSpecSubCategoryData.dart';

class OccuptionSpecSubCategoryModel {
  bool? status;
  String? message;
  List<OccuptionSpecSubCategoryData>? data;

  OccuptionSpecSubCategoryModel({this.status, this.message, this.data});

  OccuptionSpecSubCategoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];

    if (json['data'] != null) {
      data = <OccuptionSpecSubCategoryData>[];
      json['data'].forEach((v) {
        data!.add(OccuptionSpecSubCategoryData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['status'] = status;
    map['message'] = message;

    if (data != null) {
      map['data'] = data!.map((v) => v.toJson()).toList();
    }

    return map;
  }
}
