import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/EventTripModel/AddTraveller/AddTravellerData.dart';
import 'package:mpm/utils/urls.dart';

class AddTravellerRepository {
  final api = NetWorkApiService();

  Future<dynamic> addTraveller(AddTravellerData dataModel) async {
    try {
      final uri = Uri.parse(Urls.add_traveller_url);
      var request = http.MultipartRequest('POST', uri);

      _addFormFields(request, dataModel);
      _logRequestDetails(request);

      final response = await _sendRequest(request);
      return _handleResponse(response);
    } catch (e) {
      debugPrint("Error adding traveller: ${e.toString()}");
      rethrow;
    }
  }

  void _addFormFields(http.MultipartRequest request, AddTravellerData dataModel) {
    request.fields.addAll({
      'traveller_name': dataModel.travellerName ?? '',
      'trip_registered_member_id': dataModel.tripRegisteredMemberId ?? '',
      'added_by': dataModel.addedBy ?? '',
    });
  }

  void _logRequestDetails(http.MultipartRequest request) {
    debugPrint('--- Add Traveller Request ---');
    debugPrint('Endpoint: ${request.url}');
    debugPrint('Fields: ${request.fields}');
    debugPrint('----------------------------');
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
        "message": decoded["message"] ?? "Traveller already exists.",
        "already_added": true
      };
    }

    if (response.statusCode == 200) {
      return decoded;
    }

    throw HttpException(
      'Request failed with status ${response.statusCode}',
      uri: Uri.parse(Urls.add_traveller_url),
    );
  }
}