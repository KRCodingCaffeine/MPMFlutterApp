import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/model/SamitiElection/AddElectionMember/SamitiVerifyOTPLM/SamitiVerifyOTPLMData.dart';
import 'package:mpm/model/SamitiElection/AddElectionMember/SamitiVerifyOTPLM/SamitiVerifyOTPLMModelClass.dart';
import 'package:mpm/utils/urls.dart';

class SamitiVerifyOTPLMRepository {
  Future<SamitiVerifyOTPLMModelClass> verifyOTP({
    required String memberId,
    required String otp,
    required String samitiId,
    required String samitiSubCategoryId,
    String? samitiRoleId,
    String? startYear,
    String? endYear,
  }) async {
    try {
      // API URL
      final url = Urls.samiti_verify_otp_lm_conversion_url;

      debugPrint('========================================');
      debugPrint('Samiti Verify OTP LM URL: $url');

      // Form-data fields - using x-www-form-urlencoded
      final Map<String, String> fields = {
        'member_id': memberId,
        'otp': otp,
        'samiti_id': samitiId,
        'samiti_sub_category_id': samitiSubCategoryId,
        'samiti_role_id': samitiRoleId ?? '13',
        'start_year': startYear ?? '',
        'end_year': endYear ?? '',
      };

      debugPrint('Request Fields: $fields');

      // Send as x-www-form-urlencoded
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: fields,
      );

      debugPrint('========================================');
      debugPrint('Samiti Verify OTP LM Response');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Headers: ${response.headers}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('========================================');

      // Success
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        debugPrint('Parsed Response: $jsonResponse');
        return SamitiVerifyOTPLMModelClass.fromJson(jsonResponse);
      }

      // Server error
      throw Exception(
          'Server Error: ${response.statusCode} - ${response.body}');
    } catch (e) {
      debugPrint('========================================');
      debugPrint('Samiti Verify OTP LM Repository Error: $e');
      debugPrint('========================================');
      rethrow;
    }
  }
}
