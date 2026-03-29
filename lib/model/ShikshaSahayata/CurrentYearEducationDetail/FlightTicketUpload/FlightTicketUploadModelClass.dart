import 'FlightTicketUploadData.dart';

class FlightTicketUploadModelClass {
  final bool status;
  final int code;
  final String message;
  final FlightTicketUploadData? data;

  FlightTicketUploadModelClass({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory FlightTicketUploadModelClass.fromJson(Map<String, dynamic> json) {
    return FlightTicketUploadModelClass(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? FlightTicketUploadData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,
      'data': data?.toJson(),
    };
  }
}