import 'package:mpm/model/SaraswaniOption/SaraswaniOptionData.dart';

class SaraswaniOptionModelClass {
  bool? status;
  String? message;
  List<SaraswaniOptionData>? data;

  SaraswaniOptionModelClass({this.status, this.message, this.data});

  SaraswaniOptionModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <SaraswaniOptionData>[];
      json['data'].forEach((v) {
        data!.add(SaraswaniOptionData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
