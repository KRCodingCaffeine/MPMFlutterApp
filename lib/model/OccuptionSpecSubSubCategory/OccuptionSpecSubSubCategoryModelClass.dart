import 'OccuptionSpecSubSubCategoryData.dart';

class OccuptionSpecSubSubCategoryModelClass {
  bool? status;
  int? code;
  String? message;
  List<OccuptionSpecSubSubCategoryData>? data;

  OccuptionSpecSubSubCategoryModelClass({this.status, this.code, this.message, this.data});

  OccuptionSpecSubSubCategoryModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    message = json['message'];

    if (json['data'] != null) {
      data = <OccuptionSpecSubSubCategoryData>[];
      json['data'].forEach((v) {
        data!.add(OccuptionSpecSubSubCategoryData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['status'] = status;
    map['code'] = code;
    map['message'] = message;

    if (data != null) {
      map['data'] = data!.map((v) => v.toJson()).toList();
    }

    return map;
  }
}
