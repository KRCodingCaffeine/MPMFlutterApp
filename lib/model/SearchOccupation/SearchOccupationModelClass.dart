import 'package:mpm/model/SearchOccupation/SearchOccupationData.dart';

class SearchOccupationModelClass {
  bool? status;
  int? code;
  String? message;
  List<SearchOccupationData>? data;

  SearchOccupationModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  SearchOccupationModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    message = json['message'];

    if (json['data'] != null) {
      data = <SearchOccupationData>[];
      json['data'].forEach((v) {
        data!.add(SearchOccupationData.fromJson(v));
      });
    }
  }
}