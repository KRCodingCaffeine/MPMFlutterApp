import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/EventRegesitration/EventRegistrationData.dart';
import 'package:mpm/utils/urls.dart';

class EventRegistrationRepository {
  final api = NetWorkApiService();

  Future<dynamic> registerForEvent(EventRegistrationData dataModel) async {
    try {
      final uri = Uri.parse(Urls.event_register_url);
      var request = http.MultipartRequest('POST', uri);

      _addFormFields(request, dataModel);
      _logRequestDetails(request);

      final response = await _sendRequest(request);
      return _handleResponse(response);
    } catch (e) {
      debugPrint("Error registering for event: ${e.toString()}");
      rethrow;
    }
  }

  void _addFormFields(http.MultipartRequest request, EventRegistrationData dataModel) {
    request.fields.addAll({
      'member_id': dataModel.memberId?.toString() ?? '',
      'event_id': dataModel.eventId?.toString() ?? '',
      'event_registered_data': dataModel.eventRegisteredDate ?? '',
      'added_by': dataModel.addedBy?.toString() ?? '',
      'date_added': dataModel.dateAdded ?? '',
    });
  }

  void _logRequestDetails(http.MultipartRequest request) {
    debugPrint('--- Event Registration Request ---');
    debugPrint('Endpoint: ${request.url}');
    debugPrint('Fields: ${request.fields}');
    debugPrint('-------------------------------');
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
    if (response.statusCode != 200) {
      throw HttpException(
        'Request failed with status ${response.statusCode}',
        uri: Uri.parse(Urls.event_register_url),
      );
    }

    final decoded = jsonDecode(response.body);
    return decoded;
  }
}
