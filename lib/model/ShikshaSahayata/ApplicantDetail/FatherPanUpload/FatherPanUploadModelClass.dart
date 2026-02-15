import 'package:mpm/model/ShikshaSahayata/ApplicantDetail/FatherPanUpload/FatherPanUploadData.dart';

class FatherPanUploadModelClass {
  final bool status;
  final int code;
  final String message;
  final FatherPanUploadData? data;

  FatherPanUploadModelClass({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory FatherPanUploadModelClass.fromJson(Map<String, dynamic> json) {
    return FatherPanUploadModelClass(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? FatherPanUploadData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "code": code,
      "message": message,
      "data": data?.toJson(),
    };
  }
}
