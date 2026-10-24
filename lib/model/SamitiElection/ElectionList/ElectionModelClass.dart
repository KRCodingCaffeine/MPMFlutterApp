import 'package:mpm/model/SamitiElection/ElectionList/ElectionData.dart';

class ElectionModelClass {
  bool? status;
  int? code;
  String? message;

  int? total;
  int? limit;
  int? offset;

  List<ElectionData>? data;

  ElectionModelClass({
    this.status,
    this.code,
    this.message,
    this.total,
    this.limit,
    this.offset,
    this.data,
  });

  factory ElectionModelClass.fromJson(
      Map<String, dynamic> json,
      ) {
    return ElectionModelClass(
      status: json['status'] is bool
          ? json['status']
          : json['status']?.toString() == 'true',

      code: json['code'] is int
          ? json['code']
          : int.tryParse(
        json['code']?.toString() ?? '',
      ),

      message: json['message']?.toString(),

      total: json['total'] is int
          ? json['total']
          : int.tryParse(
        json['total']?.toString() ?? '',
      ),

      limit: json['limit'] is int
          ? json['limit']
          : int.tryParse(
        json['limit']?.toString() ?? '',
      ),

      offset: json['offset'] is int
          ? json['offset']
          : int.tryParse(
        json['offset']?.toString() ?? '',
      ),

      data: json['data'] != null
          ? (json['data'] as List)
          .map(
            (e) => ElectionData.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,
      'total': total,
      'limit': limit,
      'offset': offset,
      'data': data
          ?.map(
            (e) => e.toJson(),
      )
          .toList(),
    };
  }
}