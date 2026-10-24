import 'package:mpm/model/SamitiElection/SamitiTypes/SamitiTypeData.dart';

class SamitiTypeModelClass {
  bool? status;
  int? code;
  String? message;

  Map<String, List<SamitiTypeData>>? data;

  SamitiTypeModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory SamitiTypeModelClass.fromJson(
      Map<String, dynamic> json,
      ) {
    Map<String, List<SamitiTypeData>> parsedData = {};

    if (json['data'] != null &&
        json['data'] is Map<String, dynamic>) {
      final Map<String, dynamic> dataMap =
      json['data'] as Map<String, dynamic>;

      dataMap.forEach((key, value) {
        if (value is List) {
          parsedData[key] = value
              .map(
                (e) => SamitiTypeData.fromJson(
              e as Map<String, dynamic>,
            ),
          )
              .toList();
        }
      });
    }

    return SamitiTypeModelClass(
      status: json['status'] is bool
          ? json['status']
          : json['status']?.toString() == 'true',

      code: json['code'] is int
          ? json['code']
          : int.tryParse(
        json['code']?.toString() ?? '',
      ),

      message: json['message']?.toString(),

      data: parsedData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,

      'data': data?.map(
            (key, value) => MapEntry(
          key,
          value.map(
                (e) => e.toJson(),
          ).toList(),
        ),
      ),
    };
  }
}