import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/model/VerifyOtpLMConversion/VerifyOtpLMConversionData.dart';
import 'package:mpm/model/VerifyOtpLMConversion/VerifyOtpLMConversionModelClass.dart';
import 'package:mpm/utils/urls.dart';

class VerifyOtpLMConversionRepository {
  Future<VerifyOtpLMConversionModelClass> verifyOTP({
    required String memberId,
    required String otp,
  }) async {
    try {
      final url = Urls.verify_otp_lm_conversion_url;

      debugPrint('========================================');
      debugPrint('Verify OTP LM URL: $url');

      final verifyData = VerifyOtpLMConversionData(
        memberId: memberId,
        otp: otp,
      );

      final Map<String, String> fields = {
        'member_id': memberId,
        'otp': otp,
      };

      debugPrint(
        'Verify OTP Data: ${verifyData.toJson()}',
      );
      debugPrint('Request Fields: $fields');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: fields,
      );

      debugPrint('========================================');
      debugPrint('Verify OTP LM Response');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Headers: ${response.headers}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('========================================');

      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse is Map) {
        debugPrint('Parsed Response: $jsonResponse');
        return VerifyOtpLMConversionModelClass.fromJson(
          Map<String, dynamic>.from(jsonResponse),
        );
      }

      throw Exception(
        'Server Error: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      debugPrint('========================================');
      debugPrint('Verify OTP LM Repository Error: $e');
      debugPrint('========================================');
      rethrow;
    }
  }
}
