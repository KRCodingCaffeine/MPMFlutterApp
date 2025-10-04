import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/EventTripModel/TripMemberRegistration/TripMemberRegistrationData.dart';
import 'package:mpm/utils/urls.dart';

class TripMemberRegistrationRepository {
  final api = NetWorkApiService();

  Future<dynamic> registerForTrip(TripMemberRegistrationData dataModel) async {
    try {
      final uri = Uri.parse(Urls.trip_member_register_url);
      var request = http.MultipartRequest('POST', uri);

      _addFormFields(request, dataModel);
      _logRequestDetails(request);

      final response = await _sendRequest(request);
      return _handleResponse(response);
    } catch (e) {
      debugPrint("Error registering for trip: ${e.toString()}");
      rethrow;
    }
  }

  void _addFormFields(http.MultipartRequest request, TripMemberRegistrationData dataModel) {
    request.fields.addAll({
      'member_id': dataModel.memberId?.toString() ?? '',
      'trip_id': dataModel.tripId?.toString() ?? '',
      'added_by': dataModel.addedBy?.toString() ?? '',
      'traveller_names': jsonEncode(
        dataModel.travellerNames
            ?.map((t) => {"traveller_name": t})
            .toList() ?? [],
      ),
    });
  }

  void _logRequestDetails(http.MultipartRequest request) {
    debugPrint('--- Trip Registration Request ---');
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
    final decoded = jsonDecode(response.body);

    if (response.statusCode == 409) {
      return {
        "status": true,
        "message": decoded["message"] ?? "Member already registered for this trip.",
        "already_registered": true
      };
    }

    if (response.statusCode == 200) {
      return decoded;
    }

    throw HttpException(
      'Request failed with status ${response.statusCode}',
      uri: Uri.parse(Urls.trip_member_register_url),
    );
  }
}
