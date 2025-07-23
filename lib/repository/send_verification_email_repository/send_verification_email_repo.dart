import 'dart:convert';
import 'dart:developer';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/EmailVerification/EmailVerificationModelClass.dart';
import 'package:mpm/utils/urls.dart';

class SendVerificationEmailRepository {
  final _api = NetWorkApiService();

  Future<EmailVerificationModelClass> sendVerificationEmail(String memberId) async {
    try {
      final Map<String, dynamic> data = {
        'member_id': memberId,
      };

      log('Sending verification email for member: $memberId');

      final response = await _api.postApi(
        data,
        Urls.send_verification_email_url,
        "", // empty string for additional path if needed
        "2", // token/version
      );

      log('Verification email response: ${response.toString()}');

      if (response != null) {
        return EmailVerificationModelClass.fromJson(response);
      } else {
        throw Exception('Empty response received');
      }
    } catch (e) {
      log('Error sending verification email: $e');
      rethrow;
    }
  }
}