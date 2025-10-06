import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/EventTripModel/CancelTripRegistration/CancelTripRegistrationModelClass.dart';
import 'package:mpm/utils/urls.dart';

class CancelTripRegistrationRepository {
  final api = NetWorkApiService();

  /// Cancel a trip registration
  Future<CancelTripRegistrationModelClass> cancelTripRegistration({
    required String tripRegisteredMemberId,
  }) async {
    try {
      final uri = Uri.parse(Urls.cancel_trip_registration_url);
      var request = http.MultipartRequest('POST', uri);

      _addFormFields(request, tripRegisteredMemberId);
      _logRequestDetails(request);

      final response = await _sendRequest(request);
      return _handleResponse(response);
    } catch (e) {
      debugPrint("Error cancelling trip registration: ${e.toString()}");
      rethrow;
    }
  }

  /// Add form fields to the multipart request
  void _addFormFields(http.MultipartRequest request, String tripRegisteredMemberId) {
    request.fields.addAll({
      'trip_registered_member_id': tripRegisteredMemberId,
    });
  }

  /// Log request details for debugging
  void _logRequestDetails(http.MultipartRequest request) {
    debugPrint('--- Cancel Trip Registration Request ---');
    debugPrint('Endpoint: ${request.url}');
    debugPrint('Fields: ${request.fields}');
    debugPrint('---------------------------------------');
  }

  /// Send multipart request and get response
  Future<http.Response> _sendRequest(http.MultipartRequest request) async {
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return response;
    } catch (e) {
      debugPrint('Error sending cancel trip registration request: ${e.toString()}');
      rethrow;
    }
  }

  /// Handle API response and convert to model
  CancelTripRegistrationModelClass _handleResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw HttpException(
        'Request failed with status ${response.statusCode}',
        uri: Uri.parse(Urls.cancel_trip_registration_url),
      );
    }

    final decoded = jsonDecode(response.body);
    return CancelTripRegistrationModelClass.fromJson(decoded);
  }
}
