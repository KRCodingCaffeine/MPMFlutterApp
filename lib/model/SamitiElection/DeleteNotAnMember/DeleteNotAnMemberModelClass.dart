import 'package:flutter/foundation.dart';

class DeleteNotAnMemberModelClass {
  bool? status;
  int? code;
  String? message;
  bool? deletedCount;

  DeleteNotAnMemberModelClass({
    this.status,
    this.code,
    this.message,
    this.deletedCount,
  });

  factory DeleteNotAnMemberModelClass.fromJson(Map<String, dynamic> json) {
    // ✅ Parse status — handle bool, "true", "success", "1"
    bool parsedStatus = false;
    final rawStatus = json['status'];

    if (rawStatus is bool) {
      parsedStatus = rawStatus;
    } else if (rawStatus != null) {
      final s = rawStatus.toString().toLowerCase().trim();
      parsedStatus = (s == 'true' || s == 'success' || s == '1');
    }

    return DeleteNotAnMemberModelClass(
      status: parsedStatus,
      code: json['code'] is int
          ? json['code']
          : int.tryParse(json['code']?.toString() ?? ''),
      message: json['message']?.toString(),
      deletedCount: json['deleted_count'] is bool
          ? json['deleted_count']
          : json['deleted_count']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,
      'deleted_count': deletedCount,
    };
  }
}