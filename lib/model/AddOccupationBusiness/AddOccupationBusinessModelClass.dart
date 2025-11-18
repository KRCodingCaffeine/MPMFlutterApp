import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mpm/model/AddOccupationBusiness/AddOccupationBusinessData.dart';

class AddOccupationBusinessModelClass {
  bool? status;
  int? code;
  String? message;
  AddOccupationBusinessData? data;

  AddOccupationBusinessModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  AddOccupationBusinessModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    message = json['message'];

    // Handle different response formats
    if (json['data'] != null) {
      if (json['data'] is Map<String, dynamic>) {
        data = AddOccupationBusinessData.fromJson(json['data']);
      } else if (json['data'] is String) {
        // If data is a string, try to parse it as JSON
        try {
          final parsedData = jsonDecode(json['data']);
          if (parsedData is Map<String, dynamic>) {
            data = AddOccupationBusinessData.fromJson(parsedData);
          }
        } catch (e) {
          debugPrint("Error parsing data string: $e");
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['status'] = status;
    map['code'] = code;
    map['message'] = message;

    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}