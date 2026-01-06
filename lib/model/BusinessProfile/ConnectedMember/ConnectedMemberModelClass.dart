import 'ConnectedMemberData.dart';

class ConnectedMemberModelClass {
  bool? status;
  int? code;
  String? message;
  List<ConnectedMemberData>? data;
  int? total;

  ConnectedMemberModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
    this.total,
  });

  ConnectedMemberModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    message = json['message'];
    total = json['total'];

    if (json['data'] != null) {
      data = <ConnectedMemberData>[];
      json['data'].forEach((v) {
        data!.add(ConnectedMemberData.fromJson(v));
      });
    } else {
      data = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['status'] = status;
    json['code'] = code;
    json['message'] = message;
    json['total'] = total;

    if (data != null) {
      json['data'] = data!.map((v) => v.toJson()).toList();
    }

    return json;
  }
}
