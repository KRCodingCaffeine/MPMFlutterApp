import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/ChangeFamilyHead/changeFamilyHeadData.dart';
import 'package:mpm/utils/urls.dart';

class ChangeFamilyHeadRepository {
  final api = NetWorkApiService();

  Future<Map<String, dynamic>> changeFamilyHead(ChangeFamilyHeadData dataModel) async {
    try {
      final uri = Uri.parse(Urls.changeFamilyHeadUrl);
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'current_family_head_id': dataModel.currentFamilyHeadId?.toString() ?? '',
          'new_family_head_id': dataModel.newFamilyHeadId?.toString() ?? '',
          'relationship_id': dataModel.relationshipId?.toString() ?? '',
          'member_id': dataModel.memberId?.toString() ?? '',
        },
      );

      debugPrint('ChangeFamilyHead API Response: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw HttpException(
          'Request failed with status ${response.statusCode}',
          uri: uri,
        );
      }
    } catch (e) {
      debugPrint("Error in changeFamilyHead: ${e.toString()}");
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw HttpException(
        'Request failed with status ${response.statusCode}',
        uri: Uri.parse(Urls.changeFamilyHeadUrl),
      );
    }

    return json.decode(response.body);
  }
}
