import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/model/SamitiElection/AddElectionMember/AddLMElection/AddLMElectionData.dart';
import 'package:mpm/model/SamitiElection/AddElectionMember/AddLMElection/AddLMElectionModelClass.dart';
import 'package:mpm/utils/urls.dart';

class AddElectionRepository {
  Future<AddLMElectionModelClass> addElection({
    required String candidateType,
    String? memberId,
    required String samitiId,
    required String samitiSubCategoryId,
    String? samitiRoleId,
    String? startYear,
    String? endYear,
    required String createdBy,
  }) async {
    try {
      // API URL
      final url = Urls.add_lm_election_url;

      debugPrint('========================================');
      debugPrint('Add Election URL: $url');

      // Build the form data as x-www-form-urlencoded
      final Map<String, String> fields = {
        "candidate_type": candidateType,
        "member_id": memberId ?? "",
        "samiti_id": samitiId,
        "samiti_sub_category_id": samitiSubCategoryId,
        "samiti_role_id": "13",
        "start_year": startYear ?? "",
        "end_year": endYear ?? "",
        "created_by": createdBy,
      };

      // Only add samiti_role_id if it has a value (optional)
      if (samitiRoleId != null && samitiRoleId.isNotEmpty) {
        fields["samiti_role_id"] = samitiRoleId;
      }

      debugPrint('Request Fields: $fields');

      // Send as x-www-form-urlencoded
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: fields, // http will automatically encode this as x-www-form-urlencoded
      );

      debugPrint('===== RESPONSE DETAILS =====');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Headers: ${response.headers}');
      debugPrint('Body: ${response.body}');
      debugPrint('============================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        debugPrint('Parsed Response: $jsonResponse');
        return AddLMElectionModelClass.fromJson(jsonResponse);
      } else {
        throw Exception('Server Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('========================================');
      debugPrint('Add Election Repository Error: $e');
      debugPrint('========================================');
      rethrow;
    }
  }
}