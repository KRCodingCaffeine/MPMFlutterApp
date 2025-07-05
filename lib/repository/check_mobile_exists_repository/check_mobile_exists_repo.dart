import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/CheckMobileExists/CheckMobileExistsModelClass.dart';
import 'package:mpm/utils/urls.dart';

class CheckMobileRepository {
  final NetWorkApiService api = NetWorkApiService();

  Future<CheckMobileModelClass> checkMobileNumberExists(String mobileNumber) async {
    try {
      Map<String, dynamic> body = {'mobile_number': mobileNumber};

      dynamic response =
      await api.postApi(body, Urls.check_mobile_exists_url, "", "2");
      print("vdgvgdv"+response.toString());
      // return checkMobileNumberExists.fromJson(response);

      debugPrint("Check Mobile API Response: $response");
      return CheckMobileModelClass.fromJson(response);
    } catch (e) {
      debugPrint("Check Mobile Error: $e");
      rethrow;
    }
  }
}
