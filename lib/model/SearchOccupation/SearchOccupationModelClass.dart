// lib/model/SearchOccupation/SearchOccupationModelClass.dart
import 'package:mpm/model/SearchOccupation/SearchOccupationData.dart';

class SearchOccupationModelClass {
  bool? status;
  int? code;
  String? message;
  List<SearchOccupationData>? data;
  int? totalResults;
  int? totalPages;

  SearchOccupationModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
    this.totalResults,
    this.totalPages,
  });

  factory SearchOccupationModelClass.fromJson(Map<String, dynamic> json) {
    return SearchOccupationModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? List<SearchOccupationData>.from(
          json['data'].map((x) => SearchOccupationData.fromJson(x)))
          : null,
      totalResults: json['result_count'] ?? json['pagination']?['total'],
      totalPages: json['pagination']?['pages'],
    );
  }
}