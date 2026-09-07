import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:mpm/model/SamitiElection/AddElectionMember/SamitiConvertToLM/SamitiConvertToLMData.dart';
import 'package:mpm/model/SamitiElection/AddElectionMember/SamitiConvertToLM/SamitiConvertToLMModelClass.dart';
import 'package:mpm/utils/urls.dart';

class SamitiConvertToLMRepository {
  Future<SamitiConvertToLMModelClass> convertToLM({
    required String memberId,
    String? mobile,
    String? whatsappNumber,
    String? email,
    String? genderId,
    String? bloodGroupId,
    String? maritalStatusId,
    String? marriageAnniversaryDate,
    required String samitiId,
    required String samitiSubCategoryId,
    String? samitiRoleId,
    String? startYear,
    String? endYear,
  }) async {
    try {
      // API URL
      final url = Urls.samiti_convert_to_lm_url;

      debugPrint('========================================');
      debugPrint('Samiti Convert To LM URL: $url');

      // Create request model
      final convertData = SamitiConvertToLMData(
        memberId: memberId,
        mobile: mobile,
        whatsappNumber: whatsappNumber,
        email: email,
        genderId: genderId,
        bloodGroupId: bloodGroupId,
        maritalStatusId: maritalStatusId,
        marriageAnniversaryDate: marriageAnniversaryDate,
        samitiId: samitiId,
        samitiSubCategoryId: samitiSubCategoryId,
        samitiRoleId: samitiRoleId,
        startYear: startYear,
        endYear: endYear,
      );

      // Form-data fields
      final Map<String, String> fields = {
        'member_id': memberId,
        'mobile': mobile ?? '',
        'whatsapp_number': whatsappNumber ?? '',
        'email': email ?? '',
        'gender_id': genderId ?? '',
        'blood_group_id': bloodGroupId ?? '',
        'marital_status_id': maritalStatusId ?? '',
        'marriage_anniversary_date': marriageAnniversaryDate ?? '',
        'samiti_id': samitiId,
        'samiti_sub_category_id': samitiSubCategoryId,
        'samiti_role_id': samitiRoleId ?? '',
        'start_year': startYear ?? '',
        'end_year': endYear ?? '',
      };

      debugPrint(
        'Convert To LM Data: ${convertData.toJson()}',
      );

      debugPrint(
        'Request Fields: $fields',
      );

      // Multipart form-data request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      // Do NOT manually set Content-Type here.
      // MultipartRequest automatically generates:
      // multipart/form-data; boundary=...
      request.headers.addAll({
        'Accept': 'application/json',
      });

      // Add form-data fields
      request.fields.addAll(fields);

      debugPrint(
        'Sending Samiti Convert To LM Request...',
      );

      // Send request
      final streamedResponse = await request.send();

      // Convert streamed response to normal response
      final response = await http.Response.fromStream(
        streamedResponse,
      );

      debugPrint('========================================');
      debugPrint('Samiti Convert To LM Response');
      debugPrint(
        'Status Code: ${response.statusCode}',
      );
      debugPrint(
        'Headers: ${response.headers}',
      );
      debugPrint(
        'Response Body: ${response.body}',
      );
      debugPrint('========================================');

      // Success
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);

        debugPrint(
          'Parsed Response: $jsonResponse',
        );

        return SamitiConvertToLMModelClass.fromJson(
          jsonResponse,
        );
      }

      // Server error
      throw Exception(
        'Server Error: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      debugPrint('========================================');
      debugPrint(
        'Samiti Convert To LM Repository Error: $e',
      );
      debugPrint('========================================');

      rethrow;
    }
  }
}
