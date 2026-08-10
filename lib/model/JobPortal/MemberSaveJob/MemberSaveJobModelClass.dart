import 'MemberSaveJobData.dart';

class MemberSaveJobModelClass {
  bool? status;
  int? code;
  String? message;
  MemberSaveJobData? data;

  MemberSaveJobModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory MemberSaveJobModelClass.fromJson(Map<String, dynamic> json) {
    return MemberSaveJobModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message']?.toString(),
      data: json['data'] != null
          ? MemberSaveJobData.fromJson(json['data'])
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
