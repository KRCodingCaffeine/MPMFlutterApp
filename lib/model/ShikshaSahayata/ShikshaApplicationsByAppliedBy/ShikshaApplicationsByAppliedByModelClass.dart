import 'package:mpm/model/ShikshaSahayata/ShikshaApplicationsByAppliedBy/ShikshaApplicationsByAppliedByData.dart';

class ShikshaApplicationsByAppliedByModelClass {
  final bool status;
  final int code;
  final String message;
  final int totalCount;
  final List<ShikshaApplicationsByAppliedByData>? data;

  ShikshaApplicationsByAppliedByModelClass({
    required this.status,
    required this.code,
    required this.message,
    required this.totalCount,
    this.data,
  });

  factory ShikshaApplicationsByAppliedByModelClass.fromJson(
      Map<String, dynamic> json) {
    return ShikshaApplicationsByAppliedByModelClass(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      totalCount: json['total_count'] ?? 0,
      data: json['data'] != null
          ? List<ShikshaApplicationsByAppliedByData>.from(
          json['data'].map((x) => ShikshaApplicationsByAppliedByData.fromJson(x)))
          : [],
    );
  }
}
