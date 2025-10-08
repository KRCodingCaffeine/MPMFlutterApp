import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/DeviceMapping/DeviceMappingData.dart';
import 'package:mpm/model/DeviceMapping/DeviceMappingModelClass.dart';
import 'package:mpm/utils/urls.dart';

class DeviceMappingRepository {
  final api = NetWorkApiService();

  /// Create or update device mapping for a member
  Future<DeviceMappingModelClass> createDeviceMapping(DeviceMappingData dataModel) async {
    try {
      final uri = Uri.parse(Urls.device_mapping_url);
      var request = http.MultipartRequest('POST', uri);

      // Add form data fields
      _addFormFields(request, dataModel);
      _logRequestDetails(request);

      // Send request
      final response = await _sendRequest(request);
      return _handleResponse(response);
    } catch (e) {
      debugPrint("❌ Error creating device mapping: ${e.toString()}");
      rethrow;
    }
  }

  /// Add all form fields from data model
  void _addFormFields(http.MultipartRequest request, DeviceMappingData dataModel) {
    request.fields.addAll({
      'member_id': dataModel.memberId ?? '',
      'device_id': dataModel.deviceId ?? '',
      'device_model': dataModel.deviceModel ?? '',
      'device_brand': dataModel.deviceBrand ?? '',
      'os_name': dataModel.osName ?? '',
      'os_version': dataModel.osVersion ?? '', // ✅ fixed key name
    });
  }

  /// Log API request details for debugging
  void _logRequestDetails(http.MultipartRequest request) {
    debugPrint('--- 📡 Device Mapping Request ---');
    debugPrint('Endpoint: ${request.url}');
    debugPrint('Fields: ${request.fields}');
    debugPrint('--------------------------------');
  }

  /// Send HTTP multipart request and return response
  Future<http.Response> _sendRequest(http.MultipartRequest request) async {
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return response;
    } catch (e) {
      debugPrint('❌ Error sending request: ${e.toString()}');
      rethrow;
    }
  }

  /// Handle API response and parse to model
  DeviceMappingModelClass _handleResponse(http.Response response) {
    final decoded = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return DeviceMappingModelClass.fromJson(decoded);
    }

    if (response.statusCode == 409) {
      return DeviceMappingModelClass(
        status: false,
        message: decoded["message"] ?? "Device already mapped.",
      );
    }

    throw HttpException(
      'Request failed with status ${response.statusCode}',
      uri: Uri.parse(Urls.device_mapping_url),
    );
  }
}
