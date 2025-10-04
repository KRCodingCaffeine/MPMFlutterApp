import 'package:mpm/model/EventTripModel/TripMemberRegisteredDetailById/TripMemberRegisteredDetailByIdData.dart';

class TripMemberRegisteredDetailByIdModelCLass {
  final bool? status;
  final String? message;
  final List<TripMemberRegisteredDetailByIdData>? data;

  TripMemberRegisteredDetailByIdModelCLass({this.status, this.message, this.data});

  factory TripMemberRegisteredDetailByIdModelCLass.fromJson(Map<String, dynamic> json) {
    return TripMemberRegisteredDetailByIdModelCLass(
      status: json['status'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => TripMemberRegisteredDetailByIdData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.map((e) => e.toJson()).toList(),
  };
}
