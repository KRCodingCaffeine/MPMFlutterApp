import 'package:mpm/model/search/SearchData.dart';

class SearchLMCodeModel {
  bool? status;
  int? code;
  String? message;
  List<SearchData>? data;

  SearchLMCodeModel({this.status, this.code, this.message, this.data});

  SearchLMCodeModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = <SearchData>[];
      json['data'].forEach((v) {
        data!.add(new SearchData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
