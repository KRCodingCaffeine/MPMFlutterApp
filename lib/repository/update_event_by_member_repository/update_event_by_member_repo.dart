import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/utils/urls.dart';

class CancelEventRepository {
  final api = NetWorkApiService();

  Future<dynamic> cancelEventRegistration({
    required String memberId,
    required String eventId,
  }) async {
    try {
      final uri = Uri.parse(Urls.update_event_by_member_url);
      var request = http.MultipartRequest('POST', uri);

      _addFormFields(request, memberId, eventId);
      _logRequestDetails(request);

      final response = await _sendRequest(request);
      return _handleResponse(response);
    } catch (e) {
      debugPrint("Error cancelling registration: ${e.toString()}");
      rethrow;
    }
  }

  void _addFormFields(http.MultipartRequest request, String memberId, String eventId) {
    request.fields.addAll({
      'member_id': memberId,
      'event_id': eventId,
      'updated_by': memberId,
    });
  }

  void _logRequestDetails(http.MultipartRequest request) {
    debugPrint('--- Cancel Event Registration Request ---');
    debugPrint('Endpoint: ${request.url}');
    debugPrint('Fields: ${request.fields}');
    debugPrint('-----------------------------------------');
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
        uri: Uri.parse(Urls.update_event_by_member_url),
      );
    }

    final decoded = jsonDecode(response.body);
    return decoded;
  }
}
