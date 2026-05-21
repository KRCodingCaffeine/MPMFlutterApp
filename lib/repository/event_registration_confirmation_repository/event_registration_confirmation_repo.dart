import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/EventRegistrationConfirmation/EventRegistrationConfirmationData.dart';
import 'package:mpm/utils/urls.dart';

class EventRegistrationConfirmationRepository {
  final api = NetWorkApiService();

  Future<dynamic> confirmEventRegistration(
      EventRegistrationConfirmationData confirmationData) async {
    try {
      final uri = Uri.parse(Urls.event_registration_confirmation);

      var request = http.MultipartRequest('POST', uri);

      request.fields.addAll({
        'event_attendees_id': confirmationData.attendeeId ?? '',
      });

      _logRequestDetails(request);

      final response = await _sendRequest(request);

      return _handleResponse(response);
    } catch (e) {
      debugPrint("Error confirming event registration: ${e.toString()}");
      rethrow;
    }
  }

  void _logRequestDetails(http.MultipartRequest request) {
    debugPrint('--- Event Registration Confirmation Request ---');

    debugPrint('Endpoint: ${request.url}');
    debugPrint('Fields: ${request.fields}');

    debugPrint('-----------------------------------------------');
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

  dynamic _handleResponse(http.Response response) {
    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return decoded;
    }

    throw HttpException(
      'Request failed with status ${response.statusCode}',
      uri: Uri.parse(Urls.event_registration_confirmation),
    );
  }
}
