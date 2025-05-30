import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/AddExistingFamilyMember/addExistingFamilyMemberData.dart';
import 'package:mpm/utils/urls.dart';

class AddExistingMemberIntoFamilyRepository {
  final api = NetWorkApiService();

  Future<Map<String, dynamic>> addExistingMember(AddExistingMemberIntoFamilyData dataModel) async {
    try {
      final uri = Uri.parse(Urls.addExistingmemberUrl);
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'relation_id': dataModel.relationId?.toString() ?? '',
          'member_id': dataModel.memberId?.toString() ?? '',
          'current_member_id': dataModel.currentMemberId?.toString() ?? '',
        },
      );

      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw HttpException(
          'Request failed with status ${response.statusCode}',
          uri: uri,
        );
      }
    } catch (e) {
      debugPrint("Error adding existing member to family: ${e.toString()}");
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw HttpException(
        'Request failed with status ${response.statusCode}',
        uri: Uri.parse(Urls.addExistingmemberUrl),
      );
    }

    final decoded = response.body;
    return decoded;
  }
}
