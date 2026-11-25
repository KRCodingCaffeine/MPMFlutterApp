import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:mpm/model/ConvertToLM/ConvertToLMData.dart';
import 'package:mpm/model/ConvertToLM/ConvertToLMModelClass.dart';
import 'package:mpm/utils/urls.dart';

class ConvertToLMRepository {
  Future<ConvertToLMModelClass> convertToLM({
    required String memberId,
    String? mobile,
    String? whatsappNumber,
    String? email,
    String? genderId,
    String? bloodGroupId,
    String? maritalStatusId,
    String? marriageAnniversaryDate,
    File? profileImage,
  }) async {
    try {
      final url = Urls.convert_to_lm_url;

      debugPrint('========================================');
      debugPrint('Convert To LM URL: $url');

      final convertData = ConvertToLMData(
        memberId: memberId,
        mobile: mobile,
        whatsappNumber: whatsappNumber,
        email: email,
        genderId: genderId,
        bloodGroupId: bloodGroupId,
        maritalStatusId: maritalStatusId,
        marriageAnniversaryDate: marriageAnniversaryDate,
      );

      final Map<String, String> fields = {
        'member_id': memberId,
        'mobile': mobile ?? '',
        'whatsapp_number': whatsappNumber ?? '',
        'email': email ?? '',
        'gender_id': genderId ?? '',
        'blood_group_id': bloodGroupId ?? '',
        'marital_status_id': maritalStatusId ?? '',
        'marriage_anniversary_date': marriageAnniversaryDate ?? '',
      };

      debugPrint(
        'Convert To LM Data: ${convertData.toJson()}',
      );

      debugPrint(
        'Request Fields: $fields',
      );

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      request.headers.addAll({
        'Accept': 'application/json',
      });

      request.fields.addAll(fields);

      if (profileImage != null && profileImage.path.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_image', profileImage.path),
        );
      }

      debugPrint(
        'Sending Convert To LM Request...',
      );

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      debugPrint('========================================');
      debugPrint('Convert To LM Response');
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

      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse is Map) {
        debugPrint(
          'Parsed Response: $jsonResponse',
        );
        return ConvertToLMModelClass.fromJson(
          Map<String, dynamic>.from(jsonResponse),
        );
      }

      throw Exception(
        'Server Error: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      debugPrint('========================================');
      debugPrint(
        'Convert To LM Repository Error: $e',
      );
      debugPrint('========================================');

      rethrow;
    }
  }
}
