import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/AddEnquiryForm/AddEnquiryFormData.dart';
import 'package:mpm/utils/urls.dart';

class EnquiryRepository {
  final api = NetWorkApiService();

  Future<dynamic> submitEnquiry(EnquiryData enquiryData) async {
    try {
      final uri = Uri.parse(Urls.submit_enquiry_url);
      var request = http.MultipartRequest('POST', uri);

      _addFormFields(request, enquiryData);
      _logRequestDetails(request);

      final response = await _sendRequest(request);
      return _handleResponse(response);
    } catch (e) {
      debugPrint("Error submitting enquiry: ${e.toString()}");
      rethrow;
    }
  }

  void _addFormFields(http.MultipartRequest request, EnquiryData enquiryData) {
    request.fields.addAll({
      'member_id': enquiryData.memberId ?? '',
      'message': enquiryData.message ?? '',
      'enquiry_status': enquiryData.enquiryStatus ?? 'pending',
      'created_by': enquiryData.memberId ?? '',
      'added_by': enquiryData.memberId ?? '',
      'created_at': enquiryData.createdAt ?? '',
    });
  }

  void _logRequestDetails(http.MultipartRequest request) {
    debugPrint('--- Enquiry Submit Request ---');
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
        uri: Uri.parse(Urls.submit_enquiry_url),
      );
    }

    final decoded = jsonDecode(response.body);
    return decoded;
  }
}
