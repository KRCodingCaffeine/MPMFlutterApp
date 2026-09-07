import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/model/SamitiElection/AddElectionMember/AddNONMElection/AddNONMElectionData.dart';

import 'package:mpm/model/SamitiElection/AddElectionMember/AddNONMElection/AddNONMElectionModelClass.dart';
import 'package:mpm/utils/urls.dart';

class AddNONMElectionRepository {
  Future<AddNONMElectionModelClass> addNMElection({
    required String firstName,
    String? middleName,
    required String lastName,
    String? mobile,
    String? email,
    String? whatsappNumber,
    required String samitiId,
    required String samitiSubCategoryId,
    String? samitiRoleId,
    String? startYear,
    String? endYear,
    required String createdBy,
  }) async {
    try {
      // API URL
      final url = Urls.add_non_member_election_url;

      debugPrint('========================================');
      debugPrint('Add NM Election URL: $url');

      // Create request model
      final electionData = AddNONMElectionData(
        candidateType: 'NOT_A_MEMBER',
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        mobile: mobile,
        email: email,
        whatsappNumber: whatsappNumber,
        samitiId: samitiId,
        samitiSubCategoryId: samitiSubCategoryId,
        samitiRoleId: samitiRoleId,
        startYear: startYear,
        endYear: endYear,
        createdBy: createdBy,
      );

      // Build x-www-form-urlencoded fields
      final Map<String, String> fields = {
        'candidate_type': 'NOT_A_MEMBER',
        'first_name': firstName,
        'middle_name': middleName ?? '',
        'last_name': lastName,
        'mobile': mobile ?? '',
        'email': email ?? '',
        'whatsapp_number': whatsappNumber ?? '',
        'samiti_id': samitiId,
        'samiti_sub_category_id': samitiSubCategoryId,
        'samiti_role_id': '13',
        'start_year': startYear ?? '',
        'end_year': endYear ?? '',
        'created_by': createdBy,
      };

      debugPrint('Add NM Election Data: ${electionData.toJson()}');
      debugPrint('Request Fields: $fields');

      // POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: fields,
      );

      debugPrint('========================================');
      debugPrint('Add NM Election Response');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Headers: ${response.headers}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('========================================');

      // Success
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);

        debugPrint(
          'Parsed Response: $jsonResponse',
        );

        return AddNONMElectionModelClass.fromJson(
          jsonResponse,
        );
      }

      // Server error
      throw Exception(
        'Server Error: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      debugPrint('========================================');
      debugPrint('Add NM Election Repository Error: $e');
      debugPrint('========================================');

      rethrow;
    }
  }
}
