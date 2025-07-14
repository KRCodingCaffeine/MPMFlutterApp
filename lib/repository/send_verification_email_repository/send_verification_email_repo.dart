import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/EmailVerification/EmailVerificationModelClass.dart';
import 'package:mpm/utils/urls.dart';

class SendVerificationEmailRepository {
  final api = NetWorkApiService();

  Future<EmailVerificationModelClass> sendVerificationEmail(String memberId) async {
    try {
      final uri = Uri.parse(Urls.send_verification_email_url);
      var request = http.MultipartRequest('POST', uri);

      _addFormFields(request, memberId);
      _logRequestDetails(request);

      final response = await _sendRequest(request);
      return _handleResponse(response);
    } catch (e) {
      debugPrint("Error sending verification email: ${e.toString()}");
      rethrow;
    }
  }

  void _addFormFields(http.MultipartRequest request, String memberId) {
    request.fields.addAll({
      'member_id': memberId,
    });
  }

  void _logRequestDetails(http.MultipartRequest request) {
    debugPrint('--- Send Verification Email Request ---');
    debugPrint('Endpoint: ${request.url}');
    debugPrint('Fields: ${request.fields}');
    debugPrint('----------------------------------------');
  }

  Future<http.Response> _sendRequest(http.MultipartRequest request) async {
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return response;
    } catch (e) {
      debugPrint('Error sending request: ${e.toString()}');
      rethrow;
    }
  }

  EmailVerificationModelClass _handleResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw HttpException(
        'Request failed with status ${response.statusCode}',
        uri: Uri.parse(Urls.send_verification_email_url),
      );
    }

    final decoded = jsonDecode(response.body);
    return EmailVerificationModelClass.fromJson(decoded);
  }
}
