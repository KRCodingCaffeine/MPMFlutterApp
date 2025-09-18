import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/RegOtp/RegOtpModelClass.dart';
import 'package:mpm/utils/urls.dart';

class RegOtpRepository {
  final NetWorkApiService api = NetWorkApiService();

  Future<RegOtpModelClass> checkRegOtp({
    required String mobileOtp,
    required String memberId,
    required String emailOtp,
  }) async {
    try {
      Map<String, dynamic> body = {
        'mobile_otp': mobileOtp,
        'member_id': memberId,
        'email_otp': emailOtp,
      };

      dynamic response =
      await api.postApi(body, Urls.reg_otp_url, "", "2");

      debugPrint("Check Reg OTP API Response: $response");

      return RegOtpModelClass.fromJson(response);
    } catch (e) {
      debugPrint("Check Reg OTP Error: $e");
      rethrow;
    }
  }
}
